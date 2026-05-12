# cmd/download_and_run_spmf_fpgrowth.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host " Download and run SPMF FP-Growth"
Write-Host "========================================"

# -----------------------------
# 1. Paths
# -----------------------------
$SpmfDir = "spmf"
$JarPath = Join-Path $SpmfDir "spmf.jar"
$ReferenceDir = Join-Path $SpmfDir "reference_outputs"
$BenchmarkDir = "data\benchmark"

New-Item -ItemType Directory -Force $SpmfDir | Out-Null
New-Item -ItemType Directory -Force $ReferenceDir | Out-Null

# -----------------------------
# 2. Check Java
# -----------------------------
Write-Host "`n[1/4] Checking Java..." -ForegroundColor Cyan

try {
    java -version
}
catch {
    Write-Host "[ERROR] Java is not installed or not available in PATH." -ForegroundColor Red
    Write-Host "Please install Java first, then rerun this script."
    exit 1
}

# -----------------------------
# 3. Download SPMF jar
# -----------------------------
Write-Host "`n[2/4] Checking SPMF jar..." -ForegroundColor Cyan

if (!(Test-Path $JarPath)) {
    Write-Host "spmf.jar not found. Downloading..."
    Invoke-WebRequest `
        -Uri "https://www.philippe-fournier-viger.com/spmf/spmf.jar" `
        -OutFile $JarPath
    Write-Host "Downloaded: $JarPath"
}
else {
    Write-Host "Found existing: $JarPath"
}

# -----------------------------
# 4. Run FP-Growth on benchmark datasets
# -----------------------------
Write-Host "`n[3/4] Running FP-Growth on benchmark datasets..." -ForegroundColor Cyan

$Jobs = @(
    @{
        Name = "chess"
        Input = "data\benchmark\chess.txt"
        Minsup = "80%"
        Output = "spmf\reference_outputs\chess_fpgrowth_minsup80pct.out"
    },
    @{
        Name = "mushroom"
        Input = "data\benchmark\mushroom.txt"
        Minsup = "30%"
        Output = "spmf\reference_outputs\mushroom_fpgrowth_minsup30pct.out"
    },
    @{
        Name = "retail"
        Input = "data\benchmark\retail.txt"
        Minsup = "0.5%"
        Output = "spmf\reference_outputs\retail_fpgrowth_minsup0_5pct.out"
    },
    @{
        Name = "T10I4D100K"
        Input = "data\benchmark\T10I4D100K.txt"
        Minsup = "1%"
        Output = "spmf\reference_outputs\T10I4D100K_fpgrowth_minsup1pct.out"
    }
)

foreach ($Job in $Jobs) {
    $Name = $Job.Name
    $InputPath = $Job.Input
    $Minsup = $Job.Minsup
    $OutputPath = $Job.Output

    if (!(Test-Path $InputPath)) {
        Write-Host "[SKIPPED] $Name input not found: $InputPath" -ForegroundColor Yellow
        continue
    }

    Write-Host "Running FP-Growth: $Name minsup=$Minsup"

    java -jar $JarPath run FPGrowth_itemsets `
        $InputPath `
        $OutputPath `
        $Minsup

    if (Test-Path $OutputPath) {
        Write-Host "[OK] Wrote $OutputPath" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Output not created for $Name" -ForegroundColor Red
        exit 1
    }
}

# -----------------------------
# 5. Done
# -----------------------------
Write-Host "`n[4/4] Done." -ForegroundColor Cyan
Write-Host ""
Write-Host "Reference outputs are in:"
Write-Host "  $ReferenceDir"
Write-Host ""
Write-Host "========================================"
Write-Host " SPMF FP-Growth reference generation DONE"
Write-Host "========================================"