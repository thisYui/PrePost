#!/bin/bash
# setup_julia_env.sh
# Run this script at the project root directory, e.g., Y:/Python/PrePost
# Purpose:
# 1. Check Julia
# 2. Generate real UUID if Project.toml is using placeholder UUID
# 3. Install packages according to Project.toml and create Manifest.toml
# 4. Check packages
# 5. Run convert Groceries if script exists

set -e

echo "=== Julia environment setup for PrePostFIM ==="
echo "Current directory: $(pwd)"

# Check Julia
echo ""
echo "[1/5] Checking Julia..."

if ! command -v julia &> /dev/null; then
    echo "Julia not found in PATH."
    echo "Install Julia first, then open a new terminal."
    echo "Command suggestion (macOS with brew):"
    echo "brew install julia"
    exit 1
fi

julia --version

# Check Project.toml
echo ""
echo "[2/5] Checking Project.toml..."

if [ ! -f "Project.toml" ]; then
    echo "Project.toml not found in current directory."
    echo "Please run this script at the project root."
    exit 1
fi

# Check for placeholder UUID and replace if needed
if grep -q 'uuid\s*=\s*"11111111-1111-1111-1111-111111111111"' Project.toml; then
    echo "Placeholder UUID found. Generating real UUID..."

    new_uuid=$(julia -e "using UUIDs; println(uuid4())")

    # Use sed to replace the UUID (different for macOS and Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/uuid\s*=\s*"11111111-1111-1111-1111-111111111111"/uuid = "'$new_uuid'"/' Project.toml
    else
        sed -i 's/uuid\s*=\s*"11111111-1111-1111-1111-111111111111"/uuid = "'$new_uuid'"/' Project.toml
    fi

    echo "Updated Project.toml UUID: $new_uuid"
else
    echo "Project.toml UUID looks OK."
fi

# Instantiate Julia environment
echo ""
echo "[3/5] Instantiating Julia environment..."

julia --project=. -e "using Pkg; Pkg.instantiate(); Pkg.resolve(); Pkg.precompile()"

if [ -f "Manifest.toml" ]; then
    echo "Manifest.toml created/updated."
else
    echo "Manifest.toml was not created. Please check Project.toml."
fi

# Test required packages
echo ""
echo "[4/5] Testing required packages..."

julia --project=. -e "using ArgParse, CSV, DataFrames, BenchmarkTools, Plots, StatsPlots, StatsBase, DataStructures; println(\"OK: all required packages loaded\")" 2>/dev/null

# Check Groceries converter
echo ""
echo "[5/5] Checking Groceries converter..."

if [ -f "scripts/convert_groceries.jl" ]; then
    if [ -f "data/application/groceries_raw.csv" ]; then
        echo "Running scripts/convert_groceries.jl..."
        julia --project=. scripts/convert_groceries.jl

        if [ -f "data/application/groceries.txt" ]; then
            echo "Created: data/application/groceries.txt"
        fi

        if [ -f "data/application/groceries_item_mapping.csv" ]; then
            echo "Created: data/application/groceries_item_mapping.csv"
        fi
    else
        echo "data/application/groceries_raw.csv not found. Skipping Groceries conversion."
    fi
else
    echo "scripts/convert_groceries.jl not found. Skipping Groceries conversion."
fi

# Summary
echo ""
echo "=== Summary ==="
echo "Julia version:"
julia --version

echo ""
echo "Project status:"
julia --project=. -e "using Pkg; Pkg.status()"

echo ""
echo "Important files:"

important_files=(
    "Project.toml"
    "Manifest.toml"
    "data/application/groceries_raw.csv"
    "data/application/groceries.txt"
    "data/application/groceries_item_mapping.csv"
)

for file in "${important_files[@]}"; do
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "?")
        echo "OK  $file  ($size bytes)"
    else
        echo "MISSING  $file"
    fi
done

echo ""
echo "Done. Julia environment is ready."

