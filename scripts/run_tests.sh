#!/bin/bash
# scripts/run_tests.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: Run Julia test suite

set -e

echo "Running Julia tests..."

JULIA_CMD="${JULIA_CMD:-julia}"

"$JULIA_CMD" --project=. tests/runtests.jl

exit $?
