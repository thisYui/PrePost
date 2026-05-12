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
JULIA_CMD="julia"
CLI_PATH="src/cli.jl"

BASIC_INPUT="data/toy/example_basic.txt"
BASIC_EXPECTED="data/toy/expected/example_basic_minsup2.out"
BASIC_OUTPUT="outputs/toy/output_basic.out"

SPECIAL_INPUT="data/toy/example_special_single_path.txt"
SPECIAL_EXPECTED="data/toy/expected/example_special_minsup2.out"
SPECIAL_OUTPUT="outputs/toy/output_special.out"

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
check_file_exists "$BASIC_INPUT"
check_file_exists "$BASIC_EXPECTED"
check_file_exists "$SPECIAL_INPUT"
check_file_exists "$SPECIAL_EXPECTED"

echo "Required files found."
echo ""

# -----------------------------
# Run basic dataset
# -----------------------------
echo "[2/5] Running basic toy dataset..."

"$JULIA_CMD" --project=. "$CLI_PATH" \
    --input "$BASIC_INPUT" \
    --minsup 2 \
    --output "$BASIC_OUTPUT"

check_file_exists "$BASIC_OUTPUT"

echo "Basic dataset finished."
echo ""

# -----------------------------
# Run special dataset
# -----------------------------
echo "[3/5] Running special single-path dataset..."

"$JULIA_CMD" --project=. "$CLI_PATH" \
    --input "$SPECIAL_INPUT" \
    --minsup 2 \
    --output "$SPECIAL_OUTPUT"

check_file_exists "$SPECIAL_OUTPUT"

echo "Special dataset finished."
echo ""

# -----------------------------
# Normalize files before compare
# -----------------------------
echo "[4/5] Normalizing outputs..."

BASIC_OUTPUT_NORM="outputs/toy/output_basic.norm.out"
BASIC_EXPECTED_NORM="outputs/toy/expected_basic.norm.out"

SPECIAL_OUTPUT_NORM="outputs/toy/output_special.norm.out"
SPECIAL_EXPECTED_NORM="outputs/toy/expected_special.norm.out"

normalize_file "$BASIC_OUTPUT" "$BASIC_OUTPUT_NORM"
normalize_file "$BASIC_EXPECTED" "$BASIC_EXPECTED_NORM"

normalize_file "$SPECIAL_OUTPUT" "$SPECIAL_OUTPUT_NORM"
normalize_file "$SPECIAL_EXPECTED" "$SPECIAL_EXPECTED_NORM"

echo "Normalization finished."
echo ""

# -----------------------------
# Compare results
# -----------------------------
echo "[5/5] Comparing results..."

HAS_ERROR=0

if diff -u "$BASIC_EXPECTED_NORM" "$BASIC_OUTPUT_NORM" > outputs/toy/basic.diff; then
    echo "[PASSED] Basic dataset output matches expected."
else
    echo ""
    echo "[FAILED] Basic dataset output does not match expected."
    cat outputs/toy/basic.diff
    HAS_ERROR=1
fi

if diff -u "$SPECIAL_EXPECTED_NORM" "$SPECIAL_OUTPUT_NORM" > outputs/toy/special.diff; then
    echo "[PASSED] Special dataset output matches expected."
else
    echo ""
    echo "[FAILED] Special dataset output does not match expected."
    cat outputs/toy/special.diff
    HAS_ERROR=1
fi

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
