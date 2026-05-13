#!/bin/bash
# clean_outputs.sh

set -e

directories=("outputs" "results" "logs")
for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "Removed $dir"
    fi
done

# Clean output files
find . -maxdepth 1 -name "*.norm.out" -type f -delete
find . -maxdepth 1 -name "*.diff" -type f -delete
find . -maxdepth 1 -name "output_*.out" -type f -delete

echo "Generated outputs cleaned."

