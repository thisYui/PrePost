#!/bin/bash
# setup_datasets.sh
# Run this script in the project root directory, e.g., /path/to/PrePost
# Purpose:
# 1. Create data folders
# 2. Create toy datasets and expected outputs
# 3. Download benchmark datasets from FIMI
# 4. Extract .dat.gz to .txt using gzip
# 5. Download Groceries raw dataset
# 6. Create Julia script to convert Groceries to numeric format

set -e

echo "=== PrePost dataset setup ==="
echo "Current directory: $(pwd)"

# ----------------------------
# 1. Create folders
# ----------------------------
echo ""
echo "[1/7] Creating folders..."

dirs=(
    "data/raw"
    "data/toy/expected"
    "data/benchmark"
    "data/application"
    "scripts"
)

for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
done

# ----------------------------
# 2. Create toy datasets
# ----------------------------
echo ""
echo "[2/7] Creating toy datasets..."

cat > "data/toy/example_basic.txt" << 'EOF'
1 2 3
1 3 4
2 3 5
1 2 3 5
2 3 4
EOF

cat > "data/toy/example_special_single_path.txt" << 'EOF'
1 2 3 4
1 2 3
1 2 3 4
1 2 3
1 2
EOF

cat > "data/toy/expected/example_basic_minsup2.out" << 'EOF'
1 #SUP: 3
2 #SUP: 4
3 #SUP: 5
4 #SUP: 2
5 #SUP: 2
1 2 #SUP: 2
1 3 #SUP: 3
2 3 #SUP: 4
2 5 #SUP: 2
3 4 #SUP: 2
3 5 #SUP: 2
1 2 3 #SUP: 2
2 3 5 #SUP: 2
EOF

cat > "data/toy/expected/example_special_minsup2.out" << 'EOF'
1 #SUP: 5
2 #SUP: 5
3 #SUP: 4
4 #SUP: 2
1 2 #SUP: 5
1 3 #SUP: 4
1 4 #SUP: 2
2 3 #SUP: 4
2 4 #SUP: 2
3 4 #SUP: 2
1 2 3 #SUP: 4
1 2 4 #SUP: 2
1 3 4 #SUP: 2
2 3 4 #SUP: 2
1 2 3 4 #SUP: 2
EOF

# ----------------------------
# 3. Download benchmark datasets
# ----------------------------
echo ""
echo "[3/7] Downloading benchmark datasets..."

declare -A benchmarks=(
    [chess]="https://fimi.uantwerpen.be/data/chess.dat.gz"
    [mushroom]="https://fimi.uantwerpen.be/data/mushroom.dat.gz"
    [retail]="https://fimi.uantwerpen.be/data/retail.dat.gz"
    [T10I4D100K]="https://fimi.uantwerpen.be/data/T10I4D100K.dat.gz"
    [accidents]="https://fimi.uantwerpen.be/data/accidents.dat.gz"
)

for name in "${!benchmarks[@]}"; do
    url="${benchmarks[$name]}"
    outfile="data/raw/$name.dat.gz"

    if [ -f "$outfile" ]; then
        echo "Already exists: $outfile"
    else
        echo "Downloading $name..."
        curl -L "$url" -o "$outfile"
    fi
done

# ----------------------------
# 4. Extract .dat.gz to .txt
# ----------------------------
echo ""
echo "[4/7] Extracting .dat.gz files to .txt..."

for name in "${!benchmarks[@]}"; do
    gz_path="data/raw/$name.dat.gz"
    out_path="data/benchmark/$name.txt"

    if [ ! -f "$gz_path" ]; then
        echo "Missing file, skipped: $gz_path"
        continue
    fi

    echo "Extracting $gz_path -> $out_path"
    gunzip -c "$gz_path" > "$out_path"
done

# ----------------------------
# 5. Download Groceries raw dataset
# ----------------------------
echo ""
echo "[5/7] Downloading Groceries raw dataset..."

groceries_url="https://raw.githubusercontent.com/stedy/Machine-Learning-with-R-datasets/master/groceries.csv"
groceries_raw="data/application/groceries_raw.csv"

if [ -f "$groceries_raw" ]; then
    echo "Already exists: $groceries_raw"
else
    echo "Downloading Groceries dataset..."
    curl -L "$groceries_url" -o "$groceries_raw"
fi

# ----------------------------
# 6. Create Julia converter script
# ----------------------------
echo ""
echo "[6/7] Creating Julia converter script..."

cat > "scripts/convert_groceries.jl" << 'JULIA_EOF'
input_path = "data/application/groceries_raw.csv"
output_path = "data/application/groceries.txt"
map_path = "data/application/groceries_item_mapping.csv"

item_to_id = Dict{String, Int}()
next_id = 1
converted_lines = String[]

for line in eachline(input_path)
    raw_items = split(strip(line), ",")
    ids = Int[]

    for raw_item in raw_items
        item = strip(raw_item)

        if isempty(item)
            continue
        end

        if !haskey(item_to_id, item)
            item_to_id[item] = next_id
            global next_id += 1
        end

        push!(ids, item_to_id[item])
    end

    ids = sort(unique(ids))
    push!(converted_lines, join(ids, " "))
end

write(output_path, join(converted_lines, "\n"))

open(map_path, "w") do io
    println(io, "id,item")
    for (item, id) in sort(collect(item_to_id), by = x -> x[2])
        println(io, string(id, ",", item))
    end
end

println("Saved converted dataset: ", output_path)
println("Saved item mapping: ", map_path)
println("Number of transactions: ", length(converted_lines))
println("Number of unique items: ", length(item_to_id))
JULIA_EOF

# ----------------------------
# 7. Run Groceries conversion if Julia is available
# ----------------------------
echo ""
echo "[7/7] Converting Groceries with Julia..."

if ! command -v julia &> /dev/null; then
    echo "Julia not found in PATH. Please run later:"
    echo "julia scripts/convert_groceries.jl"
else
    julia scripts/convert_groceries.jl
fi

# ----------------------------
# Check results
# ----------------------------
echo ""
echo "=== Dataset files ==="

echo ""
echo "Toy datasets:"
find data/toy -type f | sort

echo ""
echo "Benchmark datasets:"
find data/benchmark -type f | sort

echo ""
echo "Application datasets:"
find data/application -type f | sort

echo ""
echo "=== Preview ==="

if [ -f "data/toy/example_basic.txt" ]; then
    echo ""
    echo "Toy basic:"
    head -n 5 "data/toy/example_basic.txt"
fi

if [ -f "data/benchmark/chess.txt" ]; then
    echo ""
    echo "Chess benchmark:"
    head -n 3 "data/benchmark/chess.txt"
fi

if [ -f "data/application/groceries_raw.csv" ]; then
    echo ""
    echo "Groceries raw:"
    head -n 3 "data/application/groceries_raw.csv"
fi

if [ -f "data/application/groceries.txt" ]; then
    echo ""
    echo "Groceries converted:"
    head -n 3 "data/application/groceries.txt"
fi

echo ""
echo "Done."

