#!/usr/bin/env bash
set -euo pipefail

mkdir -p outputs/benchmark/our results logs

DATASETS=(chess mushroom retail T10I4D100K)

# Placeholder absolute minsup values. Tune these for Chapter 4 experiments.
# chess: 500 1000
# mushroom: 1000 2000
# retail: 100 500
# T10I4D100K: 500 1000

echo "Benchmark folders are ready."
echo "Datasets: ${DATASETS[*]}"
echo
echo "This script does not run heavy benchmarks automatically."
echo "Run one dataset manually, for example:"
echo "julia --project=. src/cli.jl --input data/benchmark/chess.txt --minsup 1000 --output outputs/benchmark/our/chess_minsup1000.out"
