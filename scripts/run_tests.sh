#!/bin/bash
# run_tests.sh

set -e

echo "Running Julia tests..."
JULIA_CMD="${JULIA_CMD:-julia}"
"$JULIA_CMD" --project=. tests/runtests.jl
exit $?

