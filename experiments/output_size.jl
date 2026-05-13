using CSV
using DataFrames

include("experiment_utils.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)
const RUN_SPMF = PARSED_ARGS["spmf"]
const SELECTED_DATASETS = PARSED_ARGS["datasets"]

function run_output_size(datasets)
    ensure_dirs()
    runtime_path = joinpath(CSV_OUTPUT_DIR, "runtime_minsup.csv")
    output_path = joinpath(CSV_OUTPUT_DIR, "output_size.csv")

    if isfile(runtime_path)
        df = CSV.read(runtime_path, DataFrame)
        selected_names = Set(dataset.name for dataset in datasets)
        filtered = df[in.(df.dataset, Ref(selected_names)), :]
        if !RUN_SPMF && "algorithm" in names(filtered)
            filtered = filtered[.!startswith.(string.(filtered.algorithm), "spmf"), :]
        end
        CSV.write(output_path, select(filtered, [:dataset, :algorithm, :minsup, :minsup_ratio, :itemsets]))
        println("wrote $output_path")
        return
    end

    rows = NamedTuple[]
    algorithms = RUN_SPMF ? ("basic", "optimized", "spmf_PrePost") : ("basic", "optimized")
    for dataset in datasets
        for minsup in dataset.minsups
            for algorithm in algorithms
                is_spmf = startswith(algorithm, "spmf")
                dir = is_spmf ? SPMF_OUTPUT_DIR : OUR_OUTPUT_DIR
                out_algorithm = is_spmf ? "spmf" : algorithm
                out = joinpath(dir, output_name(dataset.name, out_algorithm, minsup))
                push!(rows, (
                    dataset = dataset.name,
                    algorithm = algorithm,
                    minsup = minsup,
                    minsup_ratio = minsup_ratio(minsup, dataset.num_transactions),
                    itemsets = parse_existing_count(out),
                ))
            end
        end
    end
    write_csv(output_path, rows)
    println("wrote $output_path")
end

run_output_size(selected_dataset_configs(DATASETS, SELECTED_DATASETS))
