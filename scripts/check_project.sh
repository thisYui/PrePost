#!/bin/bash
# check_project.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose: quickly check data, Julia env, Project.toml, Manifest.toml and necessary files.

set +e  # Continue on errors

echo "=== PrePostFIM project check ==="
echo "Current directory: $(pwd)"

ok=true

check_file() {
    local path="$1"
    local required="${2:-true}"

    if [ -f "$path" ]; then
        local size
        if [ "$(uname)" = "Darwin" ]; then
            size=$(stat -f%z "$path" 2>/dev/null)
        else
            size=$(stat -c%s "$path" 2>/dev/null)
        fi

        if [ "$size" -eq 0 ] && [ "$required" = "true" ]; then
            echo "EMPTY    $path"
            ok=false
        else
            echo "OK       $path ($size bytes)"
        fi
    else
        if [ "$required" = "true" ]; then
            echo "MISSING  $path"
            ok=false
        else
            echo "OPTIONAL $path"
        fi
    fi
}

check_dir() {
    local path="$1"
    local required="${2:-true}"

    if [ -d "$path" ]; then
        echo "OK       $path/"
    else
        if [ "$required" = "true" ]; then
            echo "MISSING  $path/"
            ok=false
        else
            echo "OPTIONAL $path/"
        fi
    fi
}

echo ""
echo "[1] Checking root files..."
check_file "Project.toml"
check_file "Manifest.toml"
check_file "README.md"
check_file "src/PrePostFIM.jl"

echo ""
echo "[2] Checking source folders..."
check_dir "src"
check_dir "src/algorithm"
check_dir "src/structures"
check_dir "src/utils"
check_dir "tests"
check_dir "experiments"
check_dir "scripts"

echo ""
echo "[3] Checking dataset folders..."
check_dir "data"
check_dir "data/toy"
check_dir "data/toy/expected"
check_dir "data/benchmark"
check_dir "data/application"

echo ""
echo "[4] Checking toy datasets..."
check_file "data/toy/example_basic.txt"
check_file "data/toy/example_special_single_path.txt"
check_file "data/toy/expected/example_basic_minsup2.out"
check_file "data/toy/expected/example_special_minsup2.out"

echo ""
echo "[5] Checking benchmark datasets..."
check_file "data/benchmark/chess.txt"
check_file "data/benchmark/mushroom.txt"
check_file "data/benchmark/retail.txt"
check_file "data/benchmark/T10I4D100K.txt"
check_file "data/benchmark/accidents.txt" "false"

echo ""
echo "[6] Checking application dataset..."
check_file "data/application/groceries_raw.csv" "false"
check_file "data/application/groceries.txt"
check_file "data/application/groceries_item_mapping.csv" "false"

echo ""
echo "[7] Checking dataset preview..."

preview_files=(
    "data/toy/example_basic.txt"
    "data/benchmark/chess.txt"
    "data/benchmark/mushroom.txt"
    "data/benchmark/retail.txt"
    "data/benchmark/T10I4D100K.txt"
    "data/application/groceries.txt"
)

for file in "${preview_files[@]}"; do
    if [ -f "$file" ]; then
        echo ""
        echo "Preview: $file"
        head -n 3 "$file"
    fi
done

echo ""
echo "[8] Checking Julia command..."

if ! command -v julia &> /dev/null; then
    echo "MISSING  julia command not found in PATH"
    ok=false
else
    julia --version
fi

echo ""
echo "[9] Checking Julia package environment..."

if command -v julia &> /dev/null && [ -f "Project.toml" ]; then
    echo "Running Pkg.status()..."
    julia --project=. -e "using Pkg; Pkg.status()"

    echo ""
    echo "Testing required packages..."
    julia --project=. -e "using ArgParse, CSV, DataFrames, BenchmarkTools, Plots, StatsBase, DataStructures; println(\"OK: required packages loaded\")"

    if [ $? -ne 0 ]; then
        echo "Julia package check failed."
        ok=false
    fi
fi

echo ""
echo "[10] Checking PrePostFIM package precompile..."

if command -v julia &> /dev/null && [ -f "src/PrePostFIM.jl" ]; then
    julia --project=. -e "using Pkg; Pkg.precompile()"

    if [ $? -ne 0 ]; then
        echo "Precompile failed."
        ok=false
    fi
fi

echo ""
echo "=== Final result ==="

if [ "$ok" = "true" ]; then
    echo "PASS: data and Julia environment look ready."
    exit 0
else
    echo "WARN: some required files or checks are missing/failed. See messages above."
    exit 1
fi

