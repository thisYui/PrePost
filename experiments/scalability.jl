include("experiment_utils.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)
const RUN_SPMF = PARSED_ARGS["spmf"]
const SELECTED_DATASETS = PARSED_ARGS["datasets"]

const SCALABILITY_RATIOS = [0.10, 0.25, 0.50, 0.75, 1.00]
const SCALABILITY_MINSUP_RATIO = 0.005

function choose_scalability_dataset(datasets)
    retail_candidates = filter(d -> d.name == "retail" && dataset_exists(d), datasets)
    !isempty(retail_candidates) && return first(retail_candidates)
    existing = filter(dataset_exists, datasets)
    isempty(existing) && error("No configured benchmark dataset exists for scalability experiment.")
    return last(existing)
end

function write_subset(dataset, ratio::Float64)
    db = read_spmf(dataset.path)
    n = max(1, round(Int, ratio * length(db.transactions)))
    subset_dir = joinpath(PROJECT_ROOT, "data", "scalability")
    mkpath(subset_dir)
    subset_path = joinpath(subset_dir, "$(dataset.name)_$(round(Int, ratio * 100)).txt")
    open(subset_path, "w") do io
        for transaction in db.transactions[1:n]
            println(io, join(transaction, " "))
        end
    end
    return subset_path, n
end

function run_subset(dataset, algorithm::AbstractString, subset_path::AbstractString, transactions::Integer, minsup::Integer)
    synthetic_dataset = (
        name = "$(dataset.name)_$(transactions)",
        path = subset_path,
        num_transactions = transactions,
        minsups = [minsup],
        medium_minsup = minsup,
    )
    if algorithm == "spmf"
        return run_spmf(synthetic_dataset, minsup)
    end
    return run_our(synthetic_dataset, algorithm, minsup)
end

function run_scalability(datasets)
    ensure_dirs()
    dataset = choose_scalability_dataset(datasets)
    rows = NamedTuple[]
    println("scalability dataset: $(dataset.name)")

    for ratio in SCALABILITY_RATIOS
        subset_path, transactions = write_subset(dataset, ratio)
        minsup = max(1, round(Int, SCALABILITY_MINSUP_RATIO * transactions))
        algorithms = RUN_SPMF ? ("optimized", "spmf") : ("optimized",)
        for algorithm in algorithms
            result = run_subset(dataset, algorithm, subset_path, transactions, minsup)
            label = algorithm == "spmf" ? "spmf_PrePost" : algorithm
            push!(rows, (
                dataset = dataset.name,
                algorithm = label,
                subset_ratio = ratio,
                transactions = transactions,
                minsup_ratio = SCALABILITY_MINSUP_RATIO,
                minsup = minsup,
                itemsets = result.itemsets,
                elapsed_seconds = result.elapsed_seconds,
                elapsed_ms = result.elapsed_seconds * 1000,
                status = result.status,
            ))
        end
    end

    path = joinpath(CSV_OUTPUT_DIR, "scalability.csv")
    write_csv(path, rows)
    println("wrote $path")
end

run_scalability(selected_dataset_configs(DATASETS, SELECTED_DATASETS))
