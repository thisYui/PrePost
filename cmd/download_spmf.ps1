# cmd/download_spmf.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host " Download SPMF jar"
Write-Host "========================================"

# -----------------------------
# 1. Paths
# -----------------------------
$SpmfDir = "spmf"
$JarPath = Join-Path $SpmfDir "spmf.jar"

New-Item -ItemType Directory -Force $SpmfDir | Out-Null

# -----------------------------
# 2. Check Java
# -----------------------------
Write-Host "`n[1/2] Checking Java..." -ForegroundColor Cyan

try {
    java -version
}
catch {
    Write-Host "[WARN] Java is not installed or not available in PATH." -ForegroundColor Yellow
    Write-Host "SPMF jar can still be downloaded, but experiments need Java to run."
}

# -----------------------------
# 3. Download SPMF jar
# -----------------------------
Write-Host "`n[2/2] Checking SPMF jar..." -ForegroundColor Cyan

if (!(Test-Path $JarPath)) {
    Write-Host "spmf.jar not found. Downloading..."

    Invoke-WebRequest `
        -Uri "https://www.philippe-fournier-viger.com/spmf/spmf.jar" `
        -OutFile $JarPath

    Write-Host "[OK] Downloaded: $JarPath" -ForegroundColor Green
}
else {
    Write-Host "[OK] Found existing: $JarPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================"
Write-Host " SPMF download DONE"
Write-Host "========================================"
Write-Host "Jar path:"
Write-Host "  $JarPath"