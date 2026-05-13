include("experiment_utils.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)
const SELECTED_DATASETS = PARSED_ARGS["datasets"]

function measure_memory(dataset, algorithm::AbstractString, minsup::Integer)
    if !dataset_exists(dataset)
        return (
            dataset = dataset.name,
            algorithm = algorithm,
            minsup = minsup,
            itemsets = 0,
            elapsed_seconds = NaN,
            allocated_bytes = 0,
            allocated_mb = NaN,
            peak_memory_mb = NaN,
            measured_memory_type = "none",
            status = "MISSING_DATASET",
        )
    end

    try
        db = read_spmf(dataset.path)
        result_ref = Ref{Any}()
        elapsed = @elapsed allocated = @allocated begin
            result_ref[] = algorithm == "basic" ? prepost_basic(db, minsup) : prepost_optimized(db, minsup)
        end
        results = result_ref[]
        write_spmf_output(joinpath(OUR_OUTPUT_DIR, output_name(dataset.name, algorithm, minsup)), results)
        allocated_mb = allocated / 1024^2
        return (
            dataset = dataset.name,
            algorithm = algorithm,
            minsup = minsup,
            itemsets = length(results),
            elapsed_seconds = elapsed,
            allocated_bytes = allocated,
            allocated_mb = allocated_mb,
            peak_memory_mb = NaN,
            measured_memory_type = "julia_allocated_bytes",
            status = "WARN: peak RSS unavailable in-process; allocated bytes recorded",
        )
    catch err
        return (
            dataset = dataset.name,
            algorithm = algorithm,
            minsup = minsup,
            itemsets = 0,
            elapsed_seconds = NaN,
            allocated_bytes = 0,
            allocated_mb = NaN,
            peak_memory_mb = NaN,
            measured_memory_type = "julia_allocated_bytes",
            status = "ERROR: $(sprint(showerror, err))",
        )
    end
end

function run_memory_usage(datasets)
    ensure_dirs()
    rows = NamedTuple[]
    for dataset in datasets
        minsup = dataset.medium_minsup
        println("memory: $(dataset.name), minsup=$minsup")
        for algorithm in ALGORITHMS
            push!(rows, measure_memory(dataset, algorithm, minsup))
        end
    end
    path = joinpath(CSV_OUTPUT_DIR, "memory_usage.csv")
    write_csv(path, rows)
    println("wrote $path")
end

run_memory_usage(selected_dataset_configs(DATASETS, SELECTED_DATASETS))
