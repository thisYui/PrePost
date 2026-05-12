#!/bin/bash
# scripts/run_benchmarks.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: Run PrePost benchmark experiments

set -e

echo "========================================"
echo " Running PrePost benchmark experiments"
echo "========================================"

# ----------------------------
# 1. Prepare folders
# ----------------------------
mkdir -p "outputs/benchmark/our"
mkdir -p "results"
mkdir -p "logs"

SUMMARY_PATH="results/benchmark_summary.csv"

echo "dataset,minsup,itemsets,elapsed_seconds,output_file" > "$SUMMARY_PATH"

# ----------------------------
# 2. Benchmark configuration
# ----------------------------
declare -A jobs=(
    [chess]="data/benchmark/chess.txt:2557,2000,1500,1000,500"
    [mushroom]="data/benchmark/mushroom.txt:2438,2000,1500,1000,500"
    [retail]="data/benchmark/retail.txt:441,300,200,100,50"
    [T10I4D100K]="data/benchmark/T10I4D100K.txt:1000,750,500,250,100"
)

# ----------------------------
# 3. Check required files
# ----------------------------
echo ""
echo "[1/3] Checking benchmark datasets..."

for dataset in "${!jobs[@]}"; do
    input_path="${jobs[$dataset]%:*}"
    if [ ! -f "$input_path" ]; then
        echo "[ERROR] Missing dataset: $input_path"
        exit 1
    fi
done

echo "Benchmark datasets found."

# ----------------------------
# 4. Run benchmarks
# ----------------------------
echo ""
echo "[2/3] Running benchmarks..."

for dataset in "${!jobs[@]}"; do
    input_path="${jobs[$dataset]%:*}"
    minsups_str="${jobs[$dataset]#*:}"

    IFS=',' read -ra minsups <<< "$minsups_str"

    for minsup in "${minsups[@]}"; do
        output_path="outputs/benchmark/our/${dataset}_minsup${minsup}.out"
        log_path="logs/benchmark_${dataset}_minsup${minsup}.log"

        echo ""
        echo "Running $dataset minsup=$minsup"

        command_output=$(julia --project=. src/cli.jl \
            --input "$input_path" \
            --minsup "$minsup" \
            --output "$output_path" 2>&1 || true)

        echo "$command_output" | tee "$log_path"

        itemsets=$(echo "$command_output" | grep -o "Frequent itemsets:[^0-9]*[0-9]*" | grep -o "[0-9]*$" || echo "NA")
        elapsed=$(echo "$command_output" | grep -o "Elapsed time:[^0-9]*[0-9.]*" | grep -o "[0-9.]*$" || echo "NA")

        echo "$dataset,$minsup,$itemsets,$elapsed,$output_path" >> "$SUMMARY_PATH"

        if [ -f "$output_path" ]; then
            echo "[OK] $dataset minsup=$minsup itemsets=$itemsets elapsed=${elapsed}s"
        else
            echo "[ERROR] Output not created: $output_path"
            exit 1
        fi
    done
done

# ----------------------------
# 5. Done
# ----------------------------
echo ""
echo "[3/3] Benchmark finished."
echo "Summary written to: $SUMMARY_PATH"

echo ""
echo "========================================"
echo " Benchmark experiments DONE"
echo "========================================"
