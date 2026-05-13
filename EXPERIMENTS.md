# Experiments

This project includes scripts for the report experiments:

- correctness against SPMF PrePost
- runtime as `minsup` changes
- number of frequent itemsets as `minsup` changes
- memory usage for `basic` vs `optimized`
- scalability on transaction subsets
- synthetic transaction-length sensitivity

## Inputs

Download benchmark datasets from the SPMF dataset page or the FIMI Repository, then place them here:

```text
data/benchmark/chess.txt
data/benchmark/mushroom.txt
data/benchmark/retail.txt
data/benchmark/T10I4D100K.txt
```

Download `spmf.jar` and place it at:

```text
tools/spmf.jar
```

The scripts also accept the existing fallback location `spmf/spmf.jar`.

## Run

```powershell
.\cmd\run_all_experiments.ps1
.\cmd\run_all_experiments.ps1 -Spmf
.\cmd\run_all_experiments.ps1 -Datasets chess,mushroom
.\cmd\run_all_experiments.ps1 -Spmf -Datasets chess -Experiments correctness
.\cmd\run_all_experiments.ps1 -Spmf -Datasets retail -Experiments runtime_minsup,plot_results
```

Use `-JuliaCmd` when Julia is not available as `julia` on `PATH`.

## Outputs

CSV files are written to `outputs/csv/`:

- `correctness.csv`
- `runtime_minsup.csv`
- `output_size.csv`
- `memory_usage.csv`
- `scalability.csv`
- `transaction_length.csv`

Mismatch details, when any, are written as `correctness_mismatches_<dataset>_<minsup>.csv`.

PNG figures are written to `outputs/figures/`:

- `runtime_<dataset>.png`
- `output_size_<dataset>.png`
- `memory_usage.png`
- `scalability.png`
- `transaction_length.png`
