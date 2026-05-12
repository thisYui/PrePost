#!/usr/bin/env bash
set -euo pipefail

echo "Running Julia tests..."
"${JULIA_CMD:-julia}" --project=. tests/runtests.jl
