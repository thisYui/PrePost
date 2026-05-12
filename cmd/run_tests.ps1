$ErrorActionPreference = "Stop"

Write-Host "Running Julia tests..."
julia --project=. tests\runtests.jl
exit $LASTEXITCODE
