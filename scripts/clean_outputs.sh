#!/bin/bash
# scripts/clean_outputs.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: Clean generated outputs, results, and logs

set -e

directories=("outputs" "results" "logs")
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "Removed $dir"
    fi
done

patterns=("*.norm.out" "*.diff" "output_*.out")
for pattern in "${patterns[@]}"; do
    find . -maxdepth 1 -type f -name "$pattern" -delete 2>/dev/null || true
done

echo "Generated outputs cleaned."
