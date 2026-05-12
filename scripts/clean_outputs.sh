#!/usr/bin/env bash
set -euo pipefail

rm -rf outputs results logs
find . -maxdepth 1 -type f \( -name "*.norm.out" -o -name "*.diff" -o -name "output_*.out" \) -delete

echo "Generated outputs cleaned."
