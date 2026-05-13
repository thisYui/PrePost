#!/bin/bash
# run_all_experiments.sh

set -e

# Parse command line arguments
SPMF=false
SPMF_ONLY=false
DATASETS=("chess" "mushroom" "retail" "T10I4D100K")
EXPERIMENTS=("correctness" "runtime_minsup" "output_size" "memory_usage" "scalability" "transaction_length" "plot_results")
JULIA_CMD="${JULIA_CMD:-julia}"
SPMF_ALGORITHM="PrePost"
SPMF_JAR_PATH="spmf/spmf.jar"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --spmf)
            SPMF=true
            shift
            ;;
        --spmf-only)
            SPMF_ONLY=true
            shift
            ;;
        --datasets)
            IFS=',' read -ra DATASETS <<< "$2"
            shift 2
            ;;
        --experiments)
            IFS=',' read -ra EXPERIMENTS <<< "$2"
            shift 2
            ;;
        --julia-cmd)
            JULIA_CMD="$2"
            shift 2
            ;;
        --spmf-algorithm)
            SPMF_ALGORITHM="$2"
            shift 2
            ;;
        --spmf-jar-path)
            SPMF_JAR_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Helper functions
normalize_list() {
    local -n arr=$1
    local -n result=$2
    result=()

    for value in "${arr[@]}"; do
        IFS=',' read -ra parts <<< "$value"
        for part in "${parts[@]}"; do
            part=$(echo "$part" | xargs)  # trim whitespace
            if [ -n "$part" ]; then
                result+=("$part")
            fi
        done
    done
}

get_transaction_count() {
    local input_path=$1
    grep -v "^[[:space:]]*$" "$input_path" | wc -l
}

convert_to_spmf_minsup() {
    local minsup=$1
    local transaction_count=$2

    if [ "$transaction_count" -le 0 ]; then
        echo "Transaction count must be positive for SPMF minsup conversion."
        exit 1
    fi

    local percent=$(awk -v m="$minsup" -v t="$transaction_count" "BEGIN {printf \"%.15f\", ((m - 0.000001) / t) * 100.0}")
    echo "${percent}%"
}

run_spmf_only() {
    echo "========================================"
    echo " Running SPMF only"
    echo "========================================"

    if ! command -v java &> /dev/null; then
        echo "[ERROR] Java is not installed or not available in PATH."
        exit 1
    fi

    if [ ! -f "$SPMF_JAR_PATH" ]; then
        echo "[ERROR] SPMF jar not found: $SPMF_JAR_PATH. Run ./download_spmf.sh first."
        exit 1
    fi

    local output_dir="outputs/spmf"
    local csv_dir="outputs/csv"

    mkdir -p "$output_dir"
    mkdir -p "$csv_dir"

    local summary_csv="$csv_dir/spmf_only.csv"
    echo "dataset,algorithm,minsup,spmf_minsup_parameter,elapsed_seconds,elapsed_ms,output_file,status" > "$summary_csv"

    # Dataset configurations
    declare -A configs
    configs[chess]="data/benchmark/chess.txt:2558,2397,2237,2077,1918,1758"
    configs[mushroom]="data/benchmark/mushroom.txt:4062,3656,3249,2843,2437,2031"
    configs[retail]="data/benchmark/retail.txt:1763,1322,882,661,441,220"
    configs[T10I4D100K]="data/benchmark/T10I4D100K.txt:2000,1500,1000,750,500,250"

    for dataset in "${DATASETS[@]}"; do
        if [ -z "${configs[$dataset]}" ]; then
            echo "[ERROR] Unknown dataset: $dataset"
            exit 1
        fi

        IFS=':' read -r input_path minsups_str <<< "${configs[$dataset]}"
        IFS=',' read -ra minsups <<< "$minsups_str"

        if [ ! -f "$input_path" ]; then
            echo "[SKIPPED] Missing dataset: $input_path"
            for minsup in "${minsups[@]}"; do
                local output_path="$output_dir/${dataset}_${SPMF_ALGORITHM}_minsup${minsup}.out"
                echo "$dataset,$SPMF_ALGORITHM,$minsup,,,,$output_path,SKIPPED_INPUT_NOT_FOUND" >> "$summary_csv"
            done
            continue
        fi

        local transaction_count=$(get_transaction_count "$input_path")

        for minsup in "${minsups[@]}"; do
            local output_path="$output_dir/${dataset}_${SPMF_ALGORITHM}_minsup${minsup}.out"
            local spmf_minsup=$(convert_to_spmf_minsup "$minsup" "$transaction_count")

            echo "SPMF only: dataset=$dataset algorithm=$SPMF_ALGORITHM minsup=$minsup spmf_minsup=$spmf_minsup"

            local start_time=$(date +%s.%N)

            java -jar "$SPMF_JAR_PATH" run "$SPMF_ALGORITHM" \
                "$input_path" \
                "$output_path" \
                "$spmf_minsup"

            local end_time=$(date +%s.%N)
            local elapsed_seconds=$(echo "$end_time - $start_time" | bc)
            local elapsed_ms=$(echo "$elapsed_seconds * 1000" | bc)

            if [ -f "$output_path" ]; then
                echo "[OK] Wrote $output_path in $elapsed_seconds seconds"
                echo "$dataset,$SPMF_ALGORITHM,$minsup,$spmf_minsup,$elapsed_seconds,$elapsed_ms,$output_path,OK" >> "$summary_csv"
            else
                echo "[ERROR] Output not created: $output_path"
                echo "$dataset,$SPMF_ALGORITHM,$minsup,$spmf_minsup,$elapsed_seconds,$elapsed_ms,$output_path,ERROR_OUTPUT_NOT_CREATED" >> "$summary_csv"
            fi
        done
    done

    echo ""
    echo "SPMF-only run completed."
    echo "Summary CSV: $summary_csv"
}

# Normalize lists
normalize_list DATASETS normalized_datasets
DATASETS=("${normalized_datasets[@]}")

normalize_list EXPERIMENTS normalized_experiments
EXPERIMENTS=("${normalized_experiments[@]}")

# Validate experiments
allowed_experiments=("correctness" "runtime_minsup" "output_size" "memory_usage" "scalability" "transaction_length" "plot_results")
for experiment in "${EXPERIMENTS[@]}"; do
    found=false
    for allowed in "${allowed_experiments[@]}"; do
        if [ "$experiment" = "$allowed" ]; then
            found=true
            break
        fi
    done
    if [ "$found" = false ]; then
        echo "[ERROR] Unknown experiment: $experiment"
        echo "Available experiments: ${allowed_experiments[*]}"
        exit 1
    fi
done

# Create directories
directories=("outputs/our" "outputs/spmf" "outputs/csv" "outputs/figures" "data/scalability" "data/synthetic")
for dir in "${directories[@]}"; do
    mkdir -p "$dir"
done

echo "SPMF enabled: $SPMF"
echo "SPMF only: $SPMF_ONLY"
echo "Datasets: ${DATASETS[*]}"
echo "Experiments: ${EXPERIMENTS[*]}"

if [ "$SPMF_ONLY" = true ]; then
    run_spmf_only
    exit 0
fi

# Run experiments
for experiment in "${EXPERIMENTS[@]}"; do
    local step="experiments/${experiment}.jl"

    local julia_args=("--project=." "$step" "--datasets" "$(IFS=,; echo "${DATASETS[*]}")")

    if [ "$SPMF" = true ]; then
        julia_args+=("--spmf")
    fi

    echo "Running $step"

    "$JULIA_CMD" "${julia_args[@]}"

    if [ $? -ne 0 ]; then
        echo "[ERROR] Experiment step failed: $step"
        exit 1
    fi
done

echo "All experiments completed."

