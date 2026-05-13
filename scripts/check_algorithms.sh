#!/bin/bash
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

# Paths
JULIA_CMD="${JULIA_CMD:-julia}"
CLI_PATH="src/cli.jl"

# Datasets array
declare -a DATASETS_NAMES=("Basic" "Special" "Sparse" "Infrequent-items" "Duplicates-long")
declare -a DATASETS_INPUT=(
    "data/toy/example_basic.txt"
    "data/toy/example_special_single_path.txt"
    "data/toy/example_sparse.txt"
    "data/toy/example_with_infrequent_items.txt"
    "data/toy/example_duplicates_long.txt"
)
declare -a DATASETS_EXPECTED=(
    "data/toy/expected/example_basic_minsup2.out"
    "data/toy/expected/example_special_minsup2.out"
    "data/toy/expected/example_sparse_minsup2.out"
    "data/toy/expected/example_with_infrequent_items_minsup2.out"
    "data/toy/expected/example_duplicates_long_minsup2.out"
)
declare -a DATASETS_OUTPUT=(
    "outputs/toy/output_basic.out"
    "outputs/toy/output_special.out"
    "outputs/toy/output_sparse.out"
    "outputs/toy/output_with_infrequent_items.out"
    "outputs/toy/output_duplicates_long.out"
)
declare -a DATASETS_DIFF=(
    "outputs/toy/basic.diff"
    "outputs/toy/special.diff"
    "outputs/toy/sparse.diff"
    "outputs/toy/with_infrequent_items.diff"
    "outputs/toy/duplicates_long.diff"
)

# Helper: check file exists
check_file_exists() {
    local path=$1
    if [ ! -f "$path" ]; then
        echo "[ERROR] Missing file: $path"
        exit 1
    fi
}

# Helper: normalize output
normalize_file() {
    local input_path=$1
    local output_path=$2
    cat "$input_path" | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        grep -v '^$' | \
        sort | \
        tee "$output_path" > /dev/null
}

# Check required files
echo "[1/5] Checking required files..."
mkdir -p "outputs/toy"

check_file_exists "$CLI_PATH"
for i in "${!DATASETS_INPUT[@]}"; do
    check_file_exists "${DATASETS_INPUT[$i]}"
    check_file_exists "${DATASETS_EXPECTED[$i]}"
done

echo "Required files found."
echo ""

# Run toy datasets
echo "[2/5] Running 5 toy datasets..."

for i in "${!DATASETS_NAMES[@]}"; do
    echo "Running ${DATASETS_NAMES[$i]} dataset..."
    "$JULIA_CMD" --project=. "$CLI_PATH" --input "${DATASETS_INPUT[$i]}" --minsup 2 --output "${DATASETS_OUTPUT[$i]}"

    if [ $? -ne 0 ]; then
        echo "[ERROR] Julia CLI failed on ${DATASETS_NAMES[$i]} dataset."
        exit 1
    fi

    check_file_exists "${DATASETS_OUTPUT[$i]}"
done

echo "All toy datasets finished."
echo ""

# Normalize files before compare
echo "[3/5] Normalizing outputs..."

for i in "${!DATASETS_NAMES[@]}"; do
    slug=$(echo "${DATASETS_NAMES[$i]}" | tr '[:upper:]' '[:lower:]' | sed 's/-/_/g')
    output_norm="outputs/toy/output_${slug}.norm.out"
    expected_norm="outputs/toy/expected_${slug}.norm.out"
    normalize_file "${DATASETS_OUTPUT[$i]}" "$output_norm"
    normalize_file "${DATASETS_EXPECTED[$i]}" "$expected_norm"
done

echo "Normalization finished."
echo ""

# Compare results
echo "[4/5] Comparing results..."

has_error=false

for i in "${!DATASETS_NAMES[@]}"; do
    slug=$(echo "${DATASETS_NAMES[$i]}" | tr '[:upper:]' '[:lower:]' | sed 's/-/_/g')
    output_norm="outputs/toy/output_${slug}.norm.out"
    expected_norm="outputs/toy/expected_${slug}.norm.out"

    if ! diff -q "$expected_norm" "$output_norm" > /dev/null 2>&1; then
        echo ""
        echo "[FAILED] ${DATASETS_NAMES[$i]} dataset output does not match expected."
        diff "$expected_norm" "$output_norm"
        diff "$expected_norm" "$output_norm" > "${DATASETS_DIFF[$i]}" || true
        has_error=true
    else
        echo "[PASSED] ${DATASETS_NAMES[$i]} dataset output matches expected."
    fi
done

echo ""
echo "[5/5] Final status..."

# Final status
if [ "$has_error" = true ]; then
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

