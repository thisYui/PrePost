$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path "outputs\benchmark\our" | Out-Null
New-Item -ItemType Directory -Force -Path "results" | Out-Null
New-Item -ItemType Directory -Force -Path "logs" | Out-Null

$Datasets = @("chess", "mushroom", "retail", "T10I4D100K")

# Placeholder absolute minsup values. Tune these for Chapter 4 experiments.
$MinSup = @{
    chess = @(500, 1000)
    mushroom = @(1000, 2000)
    retail = @(100, 500)
    T10I4D100K = @(500, 1000)
}

Write-Host "Benchmark folders are ready."
Write-Host "Datasets: $($Datasets -join ', ')"
Write-Host ""
Write-Host "This script does not run heavy benchmarks automatically."
Write-Host "Run one dataset manually, for example:"
Write-Host "julia --project=. src\cli.jl --input data\benchmark\chess.txt --minsup 1000 --output outputs\benchmark\our\chess_minsup1000.out"
