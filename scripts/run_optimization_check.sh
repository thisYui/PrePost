#!/bin/bash
# scripts/run_optimization_check.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: Run optimization level 3 comparison check

set -e

mkdir -p "outputs/optimization"
mkdir -p "results"
mkdir -p "logs"

echo "Running Level 3 optimization comparison..."

JULIA_CMD="${JULIA_CMD:-julia}"

"$JULIA_CMD" --project=. scripts/optimization_check.jl

exit $?
