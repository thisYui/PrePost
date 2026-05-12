# check_project.ps1
# Chay script nay tai thu muc goc project, vi du: Y:\Python\PrePost
# Muc dich: kiem tra nhanh data, Julia env, Project.toml, Manifest.toml va cac file can thiet.

$ErrorActionPreference = "Continue"

Write-Host "=== PrePostFIM project check ===" -ForegroundColor Cyan
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray

$ok = $true

function Check-File {
    param(
        [string]$Path,
        [bool]$Required = $true
    )

    if (Test-Path $Path) {
        $item = Get-Item $Path
        if ($item.Length -eq 0 -and $Required) {
            Write-Host "EMPTY    $Path" -ForegroundColor Yellow
            $script:ok = $false
        }
        else {
            Write-Host "OK       $Path ($($item.Length) bytes)" -ForegroundColor Green
        }
    }
    else {
        if ($Required) {
            Write-Host "MISSING  $Path" -ForegroundColor Red
            $script:ok = $false
        }
        else {
            Write-Host "OPTIONAL $Path" -ForegroundColor DarkYellow
        }
    }
}

function Check-Dir {
    param(
        [string]$Path,
        [bool]$Required = $true
    )

    if (Test-Path $Path) {
        Write-Host "OK       $Path/" -ForegroundColor Green
    }
    else {
        if ($Required) {
            Write-Host "MISSING  $Path/" -ForegroundColor Red
            $script:ok = $false
        }
        else {
            Write-Host "OPTIONAL $Path/" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "`n[1] Checking root files..." -ForegroundColor Cyan
Check-File "Project.toml"
Check-File "Manifest.toml"
Check-File "README.md"
Check-File "src\PrePostFIM.jl"

Write-Host "`n[2] Checking source folders..." -ForegroundColor Cyan
Check-Dir "src"
Check-Dir "src\algorithm"
Check-Dir "src\structures"
Check-Dir "src\utils"
Check-Dir "tests"
Check-Dir "experiments"
Check-Dir "scripts"

Write-Host "`n[3] Checking dataset folders..." -ForegroundColor Cyan
Check-Dir "data"
Check-Dir "data\toy"
Check-Dir "data\toy\expected"
Check-Dir "data\benchmark"
Check-Dir "data\application"

Write-Host "`n[4] Checking toy datasets..." -ForegroundColor Cyan
Check-File "data\toy\example_basic.txt"
Check-File "data\toy\example_special_single_path.txt"
Check-File "data\toy\expected\example_basic_minsup2.out"
Check-File "data\toy\expected\example_special_minsup2.out"

Write-Host "`n[5] Checking benchmark datasets..." -ForegroundColor Cyan
Check-File "data\benchmark\chess.txt"
Check-File "data\benchmark\mushroom.txt"
Check-File "data\benchmark\retail.txt"
Check-File "data\benchmark\T10I4D100K.txt"
Check-File "data\benchmark\accidents.txt" $false

Write-Host "`n[6] Checking application dataset..." -ForegroundColor Cyan
Check-File "data\application\groceries_raw.csv" $false
Check-File "data\application\groceries.txt"
Check-File "data\application\groceries_item_mapping.csv" $false

Write-Host "`n[7] Checking dataset preview..." -ForegroundColor Cyan

$previewFiles = @(
    "data\toy\example_basic.txt",
    "data\benchmark\chess.txt",
    "data\benchmark\mushroom.txt",
    "data\benchmark\retail.txt",
    "data\benchmark\T10I4D100K.txt",
    "data\application\groceries.txt"
)

foreach ($file in $previewFiles) {
    if (Test-Path $file) {
        Write-Host "`nPreview: $file" -ForegroundColor Gray
        Get-Content $file -TotalCount 3
    }
}

Write-Host "`n[8] Checking Julia command..." -ForegroundColor Cyan

$juliaCmd = Get-Command julia -ErrorAction SilentlyContinue
if ($null -eq $juliaCmd) {
    Write-Host "MISSING  julia command not found in PATH" -ForegroundColor Red
    $ok = $false
}
else {
    julia --version
}

Write-Host "`n[9] Checking Julia package environment..." -ForegroundColor Cyan

if ($null -ne $juliaCmd -and (Test-Path "Project.toml")) {
    Write-Host "Running Pkg.status()..." -ForegroundColor Gray
    julia --project=. -e "using Pkg; Pkg.status()"

    Write-Host "`nTesting required packages..." -ForegroundColor Gray
    julia --project=. -e "using ArgParse, CSV, DataFrames, BenchmarkTools, Plots, StatsBase, DataStructures; println(""OK: required packages loaded"")"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Julia package check failed." -ForegroundColor Red
        $ok = $false
    }
}

Write-Host "`n[10] Checking PrePostFIM package precompile..." -ForegroundColor Cyan

if ($null -ne $juliaCmd -and (Test-Path "src\PrePostFIM.jl")) {
    julia --project=. -e "using Pkg; Pkg.precompile()"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Precompile failed." -ForegroundColor Red
        $ok = $false
    }
}

Write-Host "`n=== Final result ===" -ForegroundColor Cyan

if ($ok) {
    Write-Host "PASS: data and Julia environment look ready." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "WARN: some required files or checks are missing/failed. See messages above." -ForegroundColor Yellow
    exit 1
}
