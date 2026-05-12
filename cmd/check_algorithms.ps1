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
$JuliaCmd = "julia"
$CliPath = "src\cli.jl"

$BasicInput = "data\toy\example_basic.txt"
$BasicExpected = "data\toy\expected\example_basic_minsup2.out"
$BasicOutput = "outputs\toy\output_basic.out"

$SpecialInput = "data\toy\example_special_single_path.txt"
$SpecialExpected = "data\toy\expected\example_special_minsup2.out"
$SpecialOutput = "outputs\toy\output_special.out"

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
Check-FileExists $BasicInput
Check-FileExists $BasicExpected
Check-FileExists $SpecialInput
Check-FileExists $SpecialExpected

Write-Host "Required files found.`n" -ForegroundColor Green

# -----------------------------
# Run basic dataset
# -----------------------------
Write-Host "[2/5] Running basic toy dataset..." -ForegroundColor Yellow

& $JuliaCmd --project=. $CliPath --input $BasicInput --minsup 2 --output $BasicOutput

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Julia CLI failed on basic dataset." -ForegroundColor Red
    exit 1
}

Check-FileExists $BasicOutput
Write-Host "Basic dataset finished.`n" -ForegroundColor Green

# -----------------------------
# Run special dataset
# -----------------------------
Write-Host "[3/5] Running special single-path dataset..." -ForegroundColor Yellow

& $JuliaCmd --project=. $CliPath --input $SpecialInput --minsup 2 --output $SpecialOutput

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Julia CLI failed on special dataset." -ForegroundColor Red
    exit 1
}

Check-FileExists $SpecialOutput
Write-Host "Special dataset finished.`n" -ForegroundColor Green

# -----------------------------
# Normalize files before compare
# -----------------------------
Write-Host "[4/5] Normalizing outputs..." -ForegroundColor Yellow

$BasicOutputNorm = "outputs\toy\output_basic.norm.out"
$BasicExpectedNorm = "outputs\toy\expected_basic.norm.out"

$SpecialOutputNorm = "outputs\toy\output_special.norm.out"
$SpecialExpectedNorm = "outputs\toy\expected_special.norm.out"

Normalize-File $BasicOutput $BasicOutputNorm
Normalize-File $BasicExpected $BasicExpectedNorm

Normalize-File $SpecialOutput $SpecialOutputNorm
Normalize-File $SpecialExpected $SpecialExpectedNorm

Write-Host "Normalization finished.`n" -ForegroundColor Green

# -----------------------------
# Compare results
# -----------------------------
Write-Host "[5/5] Comparing results..." -ForegroundColor Yellow

$BasicDiff = Compare-Object `
    (Get-Content $BasicExpectedNorm) `
    (Get-Content $BasicOutputNorm)

$SpecialDiff = Compare-Object `
    (Get-Content $SpecialExpectedNorm) `
    (Get-Content $SpecialOutputNorm)

$HasError = $false

if ($BasicDiff) {
    Write-Host "`n[FAILED] Basic dataset output does not match expected." -ForegroundColor Red
    $BasicDiff | Format-Table
    $HasError = $true
} else {
    Write-Host "[PASSED] Basic dataset output matches expected." -ForegroundColor Green
}

if ($SpecialDiff) {
    Write-Host "`n[FAILED] Special dataset output does not match expected." -ForegroundColor Red
    $SpecialDiff | Format-Table
    $HasError = $true
} else {
    Write-Host "[PASSED] Special dataset output matches expected." -ForegroundColor Green
}

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
