#!/bin/bash
# run_optimization_check.sh

set -e

mkdir -p "outputs/optimization"
mkdir -p "results"
mkdir -p "logs"

echo "Running Level 3 optimization comparison..."
JULIA_CMD="${JULIA_CMD:-julia}"
"$JULIA_CMD" --project=. experiments/optimization_check.jl
exit $?

