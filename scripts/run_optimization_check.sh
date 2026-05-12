#!/usr/bin/env bash
set -euo pipefail

mkdir -p outputs/optimization results logs

echo "Running Level 3 optimization comparison..."
julia --project=. scripts/optimization_check.jl
