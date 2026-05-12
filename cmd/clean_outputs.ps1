$ErrorActionPreference = "Stop"

$directories = @("outputs", "results", "logs")
foreach ($dir in $directories) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir
        Write-Host "Removed $dir"
    }
}

$patterns = @("*.norm.out", "*.diff", "output_*.out")
foreach ($pattern in $patterns) {
    Get-ChildItem -Path "." -File -Filter $pattern | Remove-Item -Force
}

Write-Host "Generated outputs cleaned."
