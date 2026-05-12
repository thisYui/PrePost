#!/usr/bin/env bash
set -euo pipefail

echo "Running Julia tests..."
julia --project=. tests/runtests.jl
