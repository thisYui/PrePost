# cmd/run_benchmarks.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host " Running PrePost benchmark experiments"
Write-Host "========================================"

# -----------------------------
# 1. Prepare folders
# -----------------------------
New-Item -ItemType Directory -Force -Path "outputs\benchmark\our" | Out-Null
New-Item -ItemType Directory -Force -Path "results" | Out-Null
New-Item -ItemType Directory -Force -Path "logs" | Out-Null

$SummaryPath = "results\benchmark_summary.csv"

"dataset,minsup,itemsets,elapsed_seconds,output_file" | Set-Content -Encoding UTF8 $SummaryPath

# -----------------------------
# 2. Benchmark configuration
# -----------------------------
$Jobs = @(
    @{
        Dataset = "chess"
        Input = "data\benchmark\chess.txt"
        Minsups = @(2557, 2000, 1500, 1000, 500)
    },
    @{
        Dataset = "mushroom"
        Input = "data\benchmark\mushroom.txt"
        Minsups = @(2438, 2000, 1500, 1000, 500)
    },
    @{
        Dataset = "retail"
        Input = "data\benchmark\retail.txt"
        Minsups = @(441, 300, 200, 100, 50)
    },
    @{
        Dataset = "T10I4D100K"
        Input = "data\benchmark\T10I4D100K.txt"
        Minsups = @(1000, 750, 500, 250, 100)
    }
)

# -----------------------------
# 3. Check required files
# -----------------------------
Write-Host ""
Write-Host "[1/3] Checking benchmark datasets..." -ForegroundColor Cyan

foreach ($Job in $Jobs) {
    if (!(Test-Path $Job.Input)) {
        Write-Host "[ERROR] Missing dataset: $($Job.Input)" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Benchmark datasets found."

# -----------------------------
# 4. Run benchmarks
# -----------------------------
Write-Host ""
Write-Host "[2/3] Running benchmarks..." -ForegroundColor Cyan

foreach ($Job in $Jobs) {
    $Dataset = $Job.Dataset
    $InputPath = $Job.Input

    foreach ($Minsup in $Job.Minsups) {
        $OutputPath = "outputs\benchmark\our\${Dataset}_minsup${Minsup}.out"
        $LogPath = "logs\benchmark_${Dataset}_minsup${Minsup}.log"

        Write-Host ""
        Write-Host "Running $Dataset minsup=$Minsup"

        $CommandOutput = julia --project=. src\cli.jl `
            --input $InputPath `
            --minsup $Minsup `
            --output $OutputPath 2>&1

        $CommandOutput | Tee-Object -FilePath $LogPath

        $ItemsetsLine = $CommandOutput | Select-String "Frequent itemsets:"
        $ElapsedLine = $CommandOutput | Select-String "Elapsed time:"

        if ($ItemsetsLine) {
            $Itemsets = ($ItemsetsLine.ToString() -replace ".*Frequent itemsets:\s*", "").Trim()
        }
        else {
            $Itemsets = "NA"
        }

        if ($ElapsedLine) {
            $Elapsed = ($ElapsedLine.ToString() -replace ".*Elapsed time:\s*", "" -replace "\s*seconds.*", "").Trim()
        }
        else {
            $Elapsed = "NA"
        }

        "$Dataset,$Minsup,$Itemsets,$Elapsed,$OutputPath" | Add-Content -Encoding UTF8 $SummaryPath

        if (Test-Path $OutputPath) {
            Write-Host "[OK] $Dataset minsup=$Minsup itemsets=$Itemsets elapsed=${Elapsed}s" -ForegroundColor Green
        }
        else {
            Write-Host "[ERROR] Output not created: $OutputPath" -ForegroundColor Red
            exit 1
        }
    }
}

# -----------------------------
# 5. Done
# -----------------------------
Write-Host ""
Write-Host "[3/3] Benchmark finished." -ForegroundColor Cyan
Write-Host "Summary written to: $SummaryPath"

Write-Host ""
Write-Host "========================================"
Write-Host " Benchmark experiments DONE"
Write-Host "========================================"