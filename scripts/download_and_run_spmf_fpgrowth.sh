#!/bin/bash
# scripts/download_and_run_spmf_fpgrowth.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: Download SPMF jar and run FP-Growth reference implementation

set -e

echo "========================================"
echo " Download and run SPMF FP-Growth"
echo "========================================"

# ----------------------------
# 1. Paths
# ----------------------------
SPMF_DIR="spmf"
JAR_PATH="$SPMF_DIR/spmf.jar"
REFERENCE_DIR="$SPMF_DIR/reference_outputs"
BENCHMARK_DIR="data/benchmark"

mkdir -p "$SPMF_DIR"
mkdir -p "$REFERENCE_DIR"

# ----------------------------
# 2. Check Java
# ----------------------------
echo ""
echo "[1/4] Checking Java..."

if ! command -v java &> /dev/null; then
    echo "[ERROR] Java is not installed or not available in PATH."
    echo "Please install Java first, then rerun this script."
    exit 1
fi

java -version

# ----------------------------
# 3. Download SPMF jar
# ----------------------------
echo ""
echo "[2/4] Checking SPMF jar..."

if [ ! -f "$JAR_PATH" ]; then
    echo "spmf.jar not found. Downloading..."
    curl -L "https://www.philippe-fournier-viger.com/spmf/spmf.jar" -o "$JAR_PATH"
    echo "Downloaded: $JAR_PATH"
else
    echo "Found existing: $JAR_PATH"
fi

# ----------------------------
# 4. Run FP-Growth on benchmark datasets
# ----------------------------
echo ""
echo "[3/4] Running FP-Growth on benchmark datasets..."

declare -a datasets=(
    "chess:data/benchmark/chess.txt:80%:spmf/reference_outputs/chess_fpgrowth_minsup80pct.out"
    "mushroom:data/benchmark/mushroom.txt:30%:spmf/reference_outputs/mushroom_fpgrowth_minsup30pct.out"
    "retail:data/benchmark/retail.txt:0.5%:spmf/reference_outputs/retail_fpgrowth_minsup0_5pct.out"
    "T10I4D100K:data/benchmark/T10I4D100K.txt:1%:spmf/reference_outputs/T10I4D100K_fpgrowth_minsup1pct.out"
)

for job in "${datasets[@]}"; do
    IFS=':' read -r name input_path minsup output_path <<< "$job"

    if [ ! -f "$input_path" ]; then
        echo "[SKIPPED] $name input not found: $input_path"
        continue
    fi

    echo "Running FP-Growth: $name minsup=$minsup"

    java -jar "$JAR_PATH" run FPGrowth_itemsets \
        "$input_path" \
        "$output_path" \
        "$minsup"

    if [ -f "$output_path" ]; then
        echo "[OK] Wrote $output_path"
    else
        echo "[ERROR] Output not created for $name"
        exit 1
    fi
done

# ----------------------------
# 5. Done
# ----------------------------
echo ""
echo "[4/4] Done."
echo ""
echo "Reference outputs are in:"
echo "  $REFERENCE_DIR"
echo ""
echo "========================================"
echo " SPMF FP-Growth reference generation DONE"
echo "========================================"

