# ============================================================
# check_algorithms.ps1
# Check PrePost algorithm on toy datasets
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Checking PrePost Algorithm" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# -----------------------------
# Paths
# -----------------------------
$JuliaCmd = if ($env:JULIA_CMD) { $env:JULIA_CMD } else { "julia" }
$CliPath = "src\cli.jl"

$Datasets = @(
    @{
        Name = "Basic"
        Input = "data\toy\example_basic.txt"
        Expected = "data\toy\expected\example_basic_minsup2.out"
        Output = "outputs\toy\output_basic.out"
        Diff = "outputs\toy\basic.diff"
    },
    @{
        Name = "Special"
        Input = "data\toy\example_special_single_path.txt"
        Expected = "data\toy\expected\example_special_minsup2.out"
        Output = "outputs\toy\output_special.out"
        Diff = "outputs\toy\special.diff"
    },
    @{
        Name = "Sparse"
        Input = "data\toy\example_sparse.txt"
        Expected = "data\toy\expected\example_sparse_minsup2.out"
        Output = "outputs\toy\output_sparse.out"
        Diff = "outputs\toy\sparse.diff"
    },
    @{
        Name = "Infrequent-items"
        Input = "data\toy\example_with_infrequent_items.txt"
        Expected = "data\toy\expected\example_with_infrequent_items_minsup2.out"
        Output = "outputs\toy\output_with_infrequent_items.out"
        Diff = "outputs\toy\with_infrequent_items.diff"
    },
    @{
        Name = "Duplicates-long"
        Input = "data\toy\example_duplicates_long.txt"
        Expected = "data\toy\expected\example_duplicates_long_minsup2.out"
        Output = "outputs\toy\output_duplicates_long.out"
        Diff = "outputs\toy\duplicates_long.diff"
    }
)

# -----------------------------
# Helper: check file exists
# -----------------------------
function Check-FileExists {
    param (
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Host "[ERROR] Missing file: $Path" -ForegroundColor Red
        exit 1
    }
}

# -----------------------------
# Helper: normalize output
# Remove empty lines and trim spaces
# -----------------------------
function Normalize-File {
    param (
        [string]$InputPath,
        [string]$OutputPath
    )

    Get-Content $InputPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" } |
        Sort-Object |
        Set-Content -Encoding UTF8 $OutputPath
}

# -----------------------------
# Check required files
# -----------------------------
Write-Host "[1/5] Checking required files..." -ForegroundColor Yellow

New-Item -ItemType Directory -Force -Path "outputs\toy" | Out-Null

Check-FileExists $CliPath
foreach ($Dataset in $Datasets) {
    Check-FileExists $Dataset.Input
    Check-FileExists $Dataset.Expected
}

Write-Host "Required files found.`n" -ForegroundColor Green

# -----------------------------
# Run toy datasets
# -----------------------------
Write-Host "[2/5] Running 5 toy datasets..." -ForegroundColor Yellow

foreach ($Dataset in $Datasets) {
    Write-Host "Running $($Dataset.Name) dataset..."
    $InputPath = $Dataset.Input
    $OutputPath = $Dataset.Output
    & $JuliaCmd --project=. $CliPath --input $InputPath --minsup 2 --output $OutputPath

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Julia CLI failed on $($Dataset.Name) dataset." -ForegroundColor Red
        exit 1
    }

    Check-FileExists $Dataset.Output
}

Write-Host "All toy datasets finished.`n" -ForegroundColor Green

# -----------------------------
# Normalize files before compare
# -----------------------------
Write-Host "[3/5] Normalizing outputs..." -ForegroundColor Yellow

foreach ($Dataset in $Datasets) {
    $Slug = $Dataset.Name.ToLower().Replace("-", "_")
    $OutputNorm = "outputs\toy\output_$Slug.norm.out"
    $ExpectedNorm = "outputs\toy\expected_$Slug.norm.out"
    Normalize-File $Dataset.Output $OutputNorm
    Normalize-File $Dataset.Expected $ExpectedNorm
}
Write-Host "Normalization finished.`n" -ForegroundColor Green

# -----------------------------
# Compare results
# -----------------------------
Write-Host "[4/5] Comparing results..." -ForegroundColor Yellow

$HasError = $false

foreach ($Dataset in $Datasets) {
    $Slug = $Dataset.Name.ToLower().Replace("-", "_")
    $OutputNorm = "outputs\toy\output_$Slug.norm.out"
    $ExpectedNorm = "outputs\toy\expected_$Slug.norm.out"
    $Diff = Compare-Object `
        (Get-Content $ExpectedNorm) `
        (Get-Content $OutputNorm)

    if ($Diff) {
        Write-Host "`n[FAILED] $($Dataset.Name) dataset output does not match expected." -ForegroundColor Red
        $Diff | Format-Table
        $DiffPath = $Dataset.Diff
        $Diff | Out-File -Encoding UTF8 $DiffPath
        $HasError = $true
    } else {
        Write-Host "[PASSED] $($Dataset.Name) dataset output matches expected." -ForegroundColor Green
    }
}

Write-Host "`n[5/5] Final status..." -ForegroundColor Yellow

# -----------------------------
# Final status
# -----------------------------
if ($HasError) {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host " Algorithm check FAILED" -ForegroundColor Red
    Write-Host "========================================`n" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host " Algorithm check PASSED" -ForegroundColor Green
    Write-Host "========================================`n" -ForegroundColor Green
    exit 0
}
