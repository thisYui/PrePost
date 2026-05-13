include("experiment_utils.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)
const RUN_SPMF = PARSED_ARGS["spmf"]
const SELECTED_DATASETS = PARSED_ARGS["datasets"]

function runtime_row(dataset, algorithm::AbstractString, minsup::Integer, run_result)
    return (
        dataset = dataset.name,
        algorithm = algorithm,
        minsup = minsup,
        minsup_ratio = minsup_ratio(minsup, dataset.num_transactions),
        itemsets = run_result.itemsets,
        elapsed_seconds = run_result.elapsed_seconds,
        elapsed_ms = run_result.elapsed_seconds * 1000,
        output_file = run_result.output_file,
        status = run_result.status,
    )
end

function run_runtime_minsup(datasets)
    ensure_dirs()
    rows = NamedTuple[]

    for dataset in datasets
        for minsup in dataset.minsups
            println("runtime: $(dataset.name), minsup=$minsup")
            for algorithm in ALGORITHMS
                push!(rows, runtime_row(dataset, algorithm, minsup, run_our(dataset, algorithm, minsup)))
            end
            if RUN_SPMF
                push!(rows, runtime_row(dataset, "spmf_PrePost", minsup, run_spmf(dataset, minsup)))
            end
        end
    end

    path = joinpath(CSV_OUTPUT_DIR, "runtime_minsup.csv")
    write_csv(path, rows)
    println("wrote $path")
end

run_runtime_minsup(selected_dataset_configs(DATASETS, SELECTED_DATASETS))
