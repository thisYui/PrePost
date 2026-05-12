# create_retail_subsets.ps1
# Chay script nay tai thu muc goc project, vi du: Y:\Python\PrePost
# Muc dich: tao cac subset retail_10, retail_25, retail_50, retail_75, retail_100
# tu data\benchmark\retail.txt de phuc vu thi nghiem scalability.

$ErrorActionPreference = "Stop"

Write-Host "=== Create Retail subsets for scalability experiment ===" -ForegroundColor Cyan
Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray

$inputFile = "data\benchmark\retail.txt"
$outputDir = "data\subsets"

if (-not (Test-Path $inputFile)) {
    Write-Host "Missing input file: $inputFile" -ForegroundColor Red
    Write-Host "Please make sure benchmark dataset retail.txt exists." -ForegroundColor Yellow
    exit 1
}

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Write-Host "`nReading input file..." -ForegroundColor Cyan
$lines = Get-Content $inputFile
$total = $lines.Count

if ($total -eq 0) {
    Write-Host "Input file is empty: $inputFile" -ForegroundColor Red
    exit 1
}

Write-Host "Total transactions: $total" -ForegroundColor Green

$percentages = @(10, 25, 50, 75, 100)

Write-Host "`nCreating subsets..." -ForegroundColor Cyan

foreach ($p in $percentages) {
    $n = [Math]::Ceiling($total * $p / 100)
    $outputFile = Join-Path $outputDir "retail_$p.txt"

    $lines | Select-Object -First $n | Set-Content -Encoding ASCII $outputFile

    $created = Get-Item $outputFile
    Write-Host "Created $outputFile with $n / $total transactions ($($created.Length) bytes)" -ForegroundColor Green
}

Write-Host "`nPreview retail_10.txt:" -ForegroundColor Cyan
Get-Content (Join-Path $outputDir "retail_10.txt") -TotalCount 5

Write-Host "`nAll subset files:" -ForegroundColor Cyan
Get-ChildItem $outputDir\retail_*.txt | Select-Object Name, Length

Write-Host "`nDone." -ForegroundColor Green
