param(
    [switch]$Spmf,
    [string[]]$Datasets = @("chess", "mushroom", "retail", "T10I4D100K"),
    [string[]]$Experiments = @(
        "correctness",
        "runtime_minsup",
        "output_size",
        "memory_usage",
        "scalability",
        "transaction_length",
        "plot_results"
    ),
    [string]$JuliaCmd = "julia"
)

$ErrorActionPreference = "Stop"

function Normalize-List([string[]]$Values) {
    $items = @()
    foreach ($value in $Values) {
        foreach ($part in ($value -split ",")) {
            $trimmed = $part.Trim()
            if ($trimmed.Length -gt 0) {
                $items += $trimmed
            }
        }
    }
    return $items
}

$Datasets = Normalize-List $Datasets
$Experiments = Normalize-List $Experiments

$allowedExperiments = @(
    "correctness",
    "runtime_minsup",
    "output_size",
    "memory_usage",
    "scalability",
    "transaction_length",
    "plot_results"
)

foreach ($experiment in $Experiments) {
    if ($allowedExperiments -notcontains $experiment) {
        throw "Unknown experiment: $experiment`nAvailable experiments: $($allowedExperiments -join ', ')"
    }
}

Set-Location (Split-Path -Parent $PSScriptRoot)

$dirs = @(
    "outputs\our",
    "outputs\spmf",
    "outputs\csv",
    "outputs\figures",
    "data\scalability",
    "data\synthetic"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Write-Host "SPMF enabled: $($Spmf.IsPresent)"
Write-Host "Datasets: $($Datasets -join ', ')"
Write-Host "Experiments: $($Experiments -join ', ')"

foreach ($experiment in $Experiments) {
    $step = "experiments\$experiment.jl"
    $juliaArgs = @("--project=.", $step, "--datasets", ($Datasets -join ","))
    if ($Spmf.IsPresent) {
        $juliaArgs += "--spmf"
    }

    Write-Host "Running $step"
    & $JuliaCmd @juliaArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Experiment step failed: $step (exit code $LASTEXITCODE)"
    }
}

Write-Host "All experiments completed."
