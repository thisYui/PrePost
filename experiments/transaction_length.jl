using Random

include("experiment_utils.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)

const SYN_NUM_TRANSACTIONS = 10_000
const SYN_NUM_ITEMS = 1_000
const SYN_AVG_LENS = [5, 10, 20, 40, 80]
const SYN_SEED = 42
const SYN_MINSUP_RATIO = 0.01

function generate_synthetic(path::AbstractString, num_transactions::Integer, num_items::Integer, avg_len::Integer, rng)
    mkpath(dirname(path))
    open(path, "w") do io
        for _ in 1:num_transactions
            len = clamp(round(Int, randexp(rng) * avg_len), 1, num_items)
            items = sort!(randperm(rng, num_items)[1:len])
            println(io, join(items, " "))
        end
    end
end

function run_transaction_length()
    ensure_dirs()
    rows = NamedTuple[]
    rng = MersenneTwister(SYN_SEED)
    synthetic_dir = joinpath(PROJECT_ROOT, "data", "synthetic")

    for avg_len in SYN_AVG_LENS
        name = "synthetic_avglen$(avg_len)"
        path = joinpath(synthetic_dir, "$name.txt")
        println("transaction length: avg_len=$avg_len")
        generate_synthetic(path, SYN_NUM_TRANSACTIONS, SYN_NUM_ITEMS, avg_len, rng)
        minsup = max(1, round(Int, SYN_MINSUP_RATIO * SYN_NUM_TRANSACTIONS))
        dataset = (
            name = name,
            path = path,
            num_transactions = SYN_NUM_TRANSACTIONS,
            minsups = [minsup],
            medium_minsup = minsup,
        )
        result = run_our(dataset, "optimized", minsup)
        push!(rows, (
            dataset = name,
            avg_len = avg_len,
            num_transactions = SYN_NUM_TRANSACTIONS,
            num_items = SYN_NUM_ITEMS,
            minsup_ratio = SYN_MINSUP_RATIO,
            minsup = minsup,
            itemsets = result.itemsets,
            elapsed_seconds = result.elapsed_seconds,
            elapsed_ms = result.elapsed_seconds * 1000,
            status = result.status,
        ))
    end

    out = joinpath(CSV_OUTPUT_DIR, "transaction_length.csv")
    write_csv(out, rows)
    println("wrote $out")
end

run_transaction_length()
