#!/bin/bash
# create_retail_subsets.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: create retail_10, retail_25, retail_50, retail_75, retail_100 subsets
# from data/benchmark/retail.txt for scalability experiment.

set -e

echo "=== Create Retail subsets for scalability experiment ==="
echo "Current directory: $(pwd)"

input_file="data/benchmark/retail.txt"
output_dir="data/subsets"

if [ ! -f "$input_file" ]; then
    echo "Missing input file: $input_file"
    echo "Please make sure benchmark dataset retail.txt exists."
    exit 1
fi

mkdir -p "$output_dir"

echo ""
echo "Reading input file..."
mapfile -t lines < "$input_file"
total=${#lines[@]}

if [ "$total" -eq 0 ]; then
    echo "Input file is empty: $input_file"
    exit 1
fi

echo "Total transactions: $total"

percentages=(10 25 50 75 100)

echo ""
echo "Creating subsets..."

for p in "${percentages[@]}"; do
    n=$(awk "BEGIN {print int($total * $p / 100 + 0.5)}")
    output_file="$output_dir/retail_$p.txt"

    head -n "$n" "$input_file" > "$output_file"

    local size
    if [ "$(uname)" = "Darwin" ]; then
        size=$(stat -f%z "$output_file" 2>/dev/null)
    else
        size=$(stat -c%s "$output_file" 2>/dev/null)
    fi
    echo "Created $output_file with $n / $total transactions ($size bytes)"
done

echo ""
echo "Preview retail_10.txt:"
head -n 5 "$output_dir/retail_10.txt"

echo ""
echo "All subset files:"
ls -lh "$output_dir"/retail_*.txt | awk '{print $9, $5}'

echo ""
echo "Done."

