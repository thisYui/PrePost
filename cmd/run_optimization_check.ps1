$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path "outputs\optimization" | Out-Null
New-Item -ItemType Directory -Force -Path "results" | Out-Null
New-Item -ItemType Directory -Force -Path "logs" | Out-Null

Write-Host "Running Level 3 optimization comparison..."
julia --project=. scripts\optimization_check.jl
exit $LASTEXITCODE
