# setup_julia_env.ps1
# Chay script nay tai thu muc goc project, vi du: Y:\Python\PrePost
# Muc dich:
# 1. Kiem tra Julia
# 2. Tao UUID that neu Project.toml dang dung UUID mau 1111...
# 3. Cai package theo Project.toml va tao Manifest.toml
# 4. Kiem tra package
# 5. Chay convert Groceries neu script ton tai

$ErrorActionPreference = "Stop"

Write-Host "=== Julia environment setup for PrePostFIM ===" -ForegroundColor Cyan
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray

# -----------------------------
# 1. Kiem tra Julia
# -----------------------------
Write-Host "`n[1/5] Checking Julia..." -ForegroundColor Cyan

$juliaCmd = Get-Command julia -ErrorAction SilentlyContinue

if ($null -eq $juliaCmd) {
    Write-Host "Julia not found in PATH." -ForegroundColor Red
    Write-Host "Install Julia first, then reopen PowerShell." -ForegroundColor Yellow
    Write-Host "Command suggestion:" -ForegroundColor Yellow
    Write-Host "winget install --name Julia --id 9NJNWW8PVKMN -e -s msstore" -ForegroundColor Yellow
    exit 1
}

julia --version

# -----------------------------
# 2. Kiem tra Project.toml
# -----------------------------
Write-Host "`n[2/5] Checking Project.toml..." -ForegroundColor Cyan

if (-not (Test-Path "Project.toml")) {
    Write-Host "Project.toml not found in current directory." -ForegroundColor Red
    Write-Host "Please run this script at the project root." -ForegroundColor Yellow
    exit 1
}

# Neu Project.toml con UUID mau thi thay bang UUID that
$projectText = Get-Content "Project.toml" -Raw

if ($projectText -match 'uuid\s*=\s*"11111111-1111-1111-1111-111111111111"') {
    Write-Host "Placeholder UUID found. Generating real UUID..." -ForegroundColor Yellow

    $newUuid = julia -e "using UUIDs; println(uuid4())"
    $newUuid = $newUuid.Trim()

    $projectText = $projectText -replace 'uuid\s*=\s*"11111111-1111-1111-1111-111111111111"', "uuid = `"$newUuid`""
    Set-Content -Encoding UTF8 "Project.toml" $projectText

    Write-Host "Updated Project.toml UUID: $newUuid" -ForegroundColor Green
}
else {
    Write-Host "Project.toml UUID looks OK." -ForegroundColor Green
}

# -----------------------------
# 3. Cai packages va tao Manifest.toml
# -----------------------------
Write-Host "`n[3/5] Instantiating Julia environment..." -ForegroundColor Cyan

julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.resolve(); Pkg.precompile()"

if (Test-Path "Manifest.toml") {
    Write-Host "Manifest.toml created/updated." -ForegroundColor Green
}
else {
    Write-Host "Manifest.toml was not created. Please check Project.toml." -ForegroundColor Yellow
}

# -----------------------------
# 4. Kiem tra package
# -----------------------------
Write-Host "`n[4/5] Testing required packages..." -ForegroundColor Cyan

julia --project=. -e "using ArgParse, CSV, DataFrames, BenchmarkTools, Plots, StatsBase, DataStructures; println(""OK: all required packages loaded"")"

# -----------------------------
# 5. Chay convert Groceries neu co
# -----------------------------
Write-Host "`n[5/5] Checking Groceries converter..." -ForegroundColor Cyan

if (Test-Path "scripts\convert_groceries.jl") {
    if (Test-Path "data\application\groceries_raw.csv") {
        Write-Host "Running scripts\convert_groceries.jl..." -ForegroundColor Cyan
        julia --project=. scripts\convert_groceries.jl

        if (Test-Path "data\application\groceries.txt") {
            Write-Host "Created: data\application\groceries.txt" -ForegroundColor Green
        }

        if (Test-Path "data\application\groceries_item_mapping.csv") {
            Write-Host "Created: data\application\groceries_item_mapping.csv" -ForegroundColor Green
        }
    }
    else {
        Write-Host "data\application\groceries_raw.csv not found. Skipping Groceries conversion." -ForegroundColor Yellow
    }
}
else {
    Write-Host "scripts\convert_groceries.jl not found. Skipping Groceries conversion." -ForegroundColor Yellow
}

# -----------------------------
# Tom tat
# -----------------------------
Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "Julia version:" -ForegroundColor Cyan
julia --version

Write-Host "`nProject status:" -ForegroundColor Cyan
julia --project=. -e "using Pkg; Pkg.status()"

Write-Host "`nImportant files:" -ForegroundColor Cyan
$importantFiles = @(
    "Project.toml",
    "Manifest.toml",
    "data\application\groceries_raw.csv",
    "data\application\groceries.txt",
    "data\application\groceries_item_mapping.csv"
)

foreach ($file in $importantFiles) {
    if (Test-Path $file) {
        $item = Get-Item $file
        Write-Host "OK  $file  ($($item.Length) bytes)" -ForegroundColor Green
    }
    else {
        Write-Host "MISSING  $file" -ForegroundColor Yellow
    }
}

Write-Host "`nDone. Julia environment is ready." -ForegroundColor Green
