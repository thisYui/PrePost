#!/usr/bin/env bash

# ============================================================
# check_algorithms.sh
# Check PrePost algorithm on toy datasets
# ============================================================

set -e

echo ""
echo "========================================"
echo " Checking PrePost Algorithm"
echo "========================================"
echo ""

# -----------------------------
# Paths
# -----------------------------
JULIA_CMD="${JULIA_CMD:-julia}"
CLI_PATH="src/cli.jl"

DATASET_NAMES=("Basic" "Special" "Sparse" "Infrequent-items" "Duplicates-long")
DATASET_INPUTS=(
    "data/toy/example_basic.txt"
    "data/toy/example_special_single_path.txt"
    "data/toy/example_sparse.txt"
    "data/toy/example_with_infrequent_items.txt"
    "data/toy/example_duplicates_long.txt"
)
DATASET_EXPECTED=(
    "data/toy/expected/example_basic_minsup2.out"
    "data/toy/expected/example_special_minsup2.out"
    "data/toy/expected/example_sparse_minsup2.out"
    "data/toy/expected/example_with_infrequent_items_minsup2.out"
    "data/toy/expected/example_duplicates_long_minsup2.out"
)
DATASET_OUTPUTS=(
    "outputs/toy/output_basic.out"
    "outputs/toy/output_special.out"
    "outputs/toy/output_sparse.out"
    "outputs/toy/output_with_infrequent_items.out"
    "outputs/toy/output_duplicates_long.out"
)
DATASET_SLUGS=("basic" "special" "sparse" "with_infrequent_items" "duplicates_long")

# -----------------------------
# Helper: check file exists
# -----------------------------
check_file_exists() {
    local path="$1"

    if [ ! -f "$path" ]; then
        echo "[ERROR] Missing file: $path"
        exit 1
    fi
}

# -----------------------------
# Helper: normalize output
# Remove empty lines, trim spaces, sort lines
# -----------------------------
normalize_file() {
    local input_path="$1"
    local output_path="$2"

    sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$input_path" \
        | sed '/^$/d' \
        | sort \
        > "$output_path"
}

# -----------------------------
# Check required files
# -----------------------------
echo "[1/5] Checking required files..."

mkdir -p outputs/toy

check_file_exists "$CLI_PATH"
for i in "${!DATASET_NAMES[@]}"; do
    check_file_exists "${DATASET_INPUTS[$i]}"
    check_file_exists "${DATASET_EXPECTED[$i]}"
done

echo "Required files found."
echo ""

# -----------------------------
# Run toy datasets
# -----------------------------
echo "[2/5] Running 5 toy datasets..."

for i in "${!DATASET_NAMES[@]}"; do
    echo "Running ${DATASET_NAMES[$i]} dataset..."
    "$JULIA_CMD" --project=. "$CLI_PATH" \
        --input "${DATASET_INPUTS[$i]}" \
        --minsup 2 \
        --output "${DATASET_OUTPUTS[$i]}"
    check_file_exists "${DATASET_OUTPUTS[$i]}"
done

echo "All toy datasets finished."
echo ""

# -----------------------------
# Normalize files before compare
# -----------------------------
echo "[3/5] Normalizing outputs..."

for i in "${!DATASET_NAMES[@]}"; do
    normalize_file "${DATASET_OUTPUTS[$i]}" "outputs/toy/output_${DATASET_SLUGS[$i]}.norm.out"
    normalize_file "${DATASET_EXPECTED[$i]}" "outputs/toy/expected_${DATASET_SLUGS[$i]}.norm.out"
done

echo "Normalization finished."
echo ""

# -----------------------------
# Compare results
# -----------------------------
echo "[4/5] Comparing results..."

HAS_ERROR=0

for i in "${!DATASET_NAMES[@]}"; do
    output_norm="outputs/toy/output_${DATASET_SLUGS[$i]}.norm.out"
    expected_norm="outputs/toy/expected_${DATASET_SLUGS[$i]}.norm.out"
    diff_path="outputs/toy/${DATASET_SLUGS[$i]}.diff"

    if diff -u "$expected_norm" "$output_norm" > "$diff_path"; then
        echo "[PASSED] ${DATASET_NAMES[$i]} dataset output matches expected."
    else
        echo ""
        echo "[FAILED] ${DATASET_NAMES[$i]} dataset output does not match expected."
        cat "$diff_path"
        HAS_ERROR=1
    fi
done

echo ""
echo "[5/5] Final status..."

# -----------------------------
# Final status
# -----------------------------
if [ "$HAS_ERROR" -ne 0 ]; then
    echo ""
    echo "========================================"
    echo " Algorithm check FAILED"
    echo "========================================"
    echo ""
    exit 1
else
    echo ""
    echo "========================================"
    echo " Algorithm check PASSED"
    echo "========================================"
    echo ""
    exit 0
fi
