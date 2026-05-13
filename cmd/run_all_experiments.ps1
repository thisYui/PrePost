param(
    [switch]$Spmf,
    [switch]$SpmfOnly,

    [string[]]$Datasets = @("chess", "mushroom", "retail", "T10I4D100K"),

    [string[]]$Experiments = @(
        "correctness",
        "runtime_minsup",
        "output_size",
        "memory_usage",
        "scalability",
        "transaction_length",
        "plot_results"
    ),

    [string]$JuliaCmd = "julia",
    [string]$SpmfAlgorithm = "PrePost",
    [string]$SpmfJarPath = "spmf\spmf.jar"
)

$ErrorActionPreference = "Stop"

function Normalize-List([string[]]$Values) {
    $items = @()

    foreach ($value in $Values) {
        foreach ($part in ($value -split ",")) {
            $trimmed = $part.Trim()
            if ($trimmed.Length -gt 0) {
                $items += $trimmed
            }
        }
    }

    return $items
}

function Get-TransactionCount([string]$InputPath) {
    return (Get-Content -Path $InputPath | Where-Object { $_.Trim().Length -gt 0 }).Count
}

function ConvertTo-SpmfMinsupParameter([int]$Minsup, [int]$TransactionCount) {
    if ($TransactionCount -le 0) {
        throw "Transaction count must be positive for SPMF minsup conversion."
    }

    $percent = (($Minsup - 0.000001) / $TransactionCount) * 100.0
    return $percent.ToString("G17", [System.Globalization.CultureInfo]::InvariantCulture) + "%"
}

function Run-SpmfOnly {
    param(
        [string[]]$SelectedDatasets,
        [string]$Algorithm,
        [string]$JarPath
    )

    Write-Host "========================================"
    Write-Host " Running SPMF only"
    Write-Host "========================================"

    if (!(Get-Command java -ErrorAction SilentlyContinue)) {
        throw "Java is not installed or not available in PATH."
    }

    if (!(Test-Path $JarPath)) {
        throw "SPMF jar not found: $JarPath. Run cmd\download_spmf.ps1 first."
    }

    $OutputDir = "outputs\spmf"
    $CsvDir = "outputs\csv"

    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    New-Item -ItemType Directory -Force -Path $CsvDir | Out-Null

    $SummaryCsv = Join-Path $CsvDir "spmf_only.csv"
    "dataset,algorithm,minsup,spmf_minsup_parameter,elapsed_seconds,elapsed_ms,output_file,status" | Set-Content $SummaryCsv

    $configs = @{
        chess = @{
            Path = "data\benchmark\chess.txt"
            Minsups = @(2558, 2397, 2237, 2077, 1918, 1758)
        }

        mushroom = @{
            Path = "data\benchmark\mushroom.txt"
            Minsups = @(4062, 3656, 3249, 2843, 2437, 2031)
        }

        retail = @{
            Path = "data\benchmark\retail.txt"
            Minsups = @(1763, 1322, 882, 661, 441, 220)
        }

        T10I4D100K = @{
            Path = "data\benchmark\T10I4D100K.txt"
            Minsups = @(2000, 1500, 1000, 750, 500, 250)
        }
    }

    foreach ($dataset in $SelectedDatasets) {
        if (!$configs.ContainsKey($dataset)) {
            throw "Unknown dataset: $dataset. Available datasets: $($configs.Keys -join ', ')"
        }
    }

    foreach ($dataset in $SelectedDatasets) {
        $config = $configs[$dataset]
        $inputPath = $config.Path

        if (!(Test-Path $inputPath)) {
            Write-Host "[SKIPPED] Missing dataset: $inputPath" -ForegroundColor Yellow

            foreach ($minsup in $config.Minsups) {
                $outputPath = Join-Path $OutputDir "${dataset}_${Algorithm}_minsup${minsup}.out"
                "$dataset,$Algorithm,$minsup,,,,$outputPath,SKIPPED_INPUT_NOT_FOUND" | Add-Content $SummaryCsv
            }

            continue
        }

        $transactionCount = Get-TransactionCount $inputPath

        foreach ($minsup in $config.Minsups) {
            $outputPath = Join-Path $OutputDir "${dataset}_${Algorithm}_minsup${minsup}.out"
            $spmfMinsup = ConvertTo-SpmfMinsupParameter $minsup $transactionCount

            Write-Host "SPMF only: dataset=$dataset algorithm=$Algorithm minsup=$minsup spmf_minsup=$spmfMinsup" -ForegroundColor Cyan

            $startTime = Get-Date

            java -jar $JarPath run $Algorithm `
                $inputPath `
                $outputPath `
                $spmfMinsup

            $endTime = Get-Date
            $elapsedSeconds = ($endTime - $startTime).TotalSeconds
            $elapsedMs = $elapsedSeconds * 1000.0

            if (Test-Path $outputPath) {
                Write-Host "[OK] Wrote $outputPath in $elapsedSeconds seconds" -ForegroundColor Green
                "$dataset,$Algorithm,$minsup,$spmfMinsup,$elapsedSeconds,$elapsedMs,$outputPath,OK" | Add-Content $SummaryCsv
            }
            else {
                Write-Host "[ERROR] Output not created: $outputPath" -ForegroundColor Red
                "$dataset,$Algorithm,$minsup,$spmfMinsup,$elapsedSeconds,$elapsedMs,$outputPath,ERROR_OUTPUT_NOT_CREATED" | Add-Content $SummaryCsv
            }
        }
    }

    Write-Host ""
    Write-Host "SPMF-only run completed."
    Write-Host "Summary CSV: $SummaryCsv"
}

$Datasets = Normalize-List $Datasets
$Experiments = Normalize-List $Experiments

$allowedExperiments = @(
    "correctness",
    "runtime_minsup",
    "output_size",
    "memory_usage",
    "scalability",
    "transaction_length",
    "plot_results"
)

foreach ($experiment in $Experiments) {
    if ($allowedExperiments -notcontains $experiment) {
        throw "Unknown experiment: $experiment`nAvailable experiments: $($allowedExperiments -join ', ')"
    }
}

Set-Location (Split-Path -Parent $PSScriptRoot)

$dirs = @(
    "outputs\our",
    "outputs\spmf",
    "outputs\csv",
    "outputs\figures",
    "data\scalability",
    "data\synthetic"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host "SPMF enabled: $($Spmf.IsPresent)"
Write-Host "SPMF only: $($SpmfOnly.IsPresent)"
Write-Host "Datasets: $($Datasets -join ', ')"
Write-Host "Experiments: $($Experiments -join ', ')"

if ($SpmfOnly.IsPresent) {
    Run-SpmfOnly `
        -SelectedDatasets $Datasets `
        -Algorithm $SpmfAlgorithm `
        -JarPath $SpmfJarPath

    exit 0
}

foreach ($experiment in $Experiments) {
    $step = "experiments\$experiment.jl"

    $juliaArgs = @(
        "--project=.",
        $step,
        "--datasets",
        ($Datasets -join ",")
    )

    if ($Spmf.IsPresent) {
        $juliaArgs += "--spmf"
    }

    Write-Host "Running $step" -ForegroundColor Cyan

    & $JuliaCmd @juliaArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Experiment step failed: $step (exit code $LASTEXITCODE)"
    }
}

Write-Host "All experiments completed."
