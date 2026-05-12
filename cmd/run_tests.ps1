$ErrorActionPreference = "Stop"

Write-Host "Running Julia tests..."
$JuliaCmd = if ($env:JULIA_CMD) { $env:JULIA_CMD } else { "julia" }
& $JuliaCmd --project=. tests\runtests.jl
exit $LASTEXITCODE
