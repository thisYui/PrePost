using PrePostFIM

const PROJECT_ROOT = dirname(@__DIR__)

struct OptimizationDataset
    name::String
    path::String
    minsup::Int
end

function selected_datasets()
    datasets = OptimizationDataset[
        OptimizationDataset(
            "toy_basic",
            joinpath(PROJECT_ROOT, "data", "toy", "example_basic.txt"),
            2,
        ),
        OptimizationDataset(
            "toy_special_single_path",
            joinpath(PROJECT_ROOT, "data", "toy", "example_special_single_path.txt"),
            2,
        ),
        OptimizationDataset(
            "toy_sparse",
            joinpath(PROJECT_ROOT, "data", "toy", "example_sparse.txt"),
            2,
        ),
        OptimizationDataset(
            "toy_with_infrequent_items",
            joinpath(PROJECT_ROOT, "data", "toy", "example_with_infrequent_items.txt"),
            2,
        ),
        OptimizationDataset(
            "toy_duplicates_long",
            joinpath(PROJECT_ROOT, "data", "toy", "example_duplicates_long.txt"),
            2,
        ),
    ]

    if get(ENV, "RUN_SMALL_BENCHMARK", "false") == "true"
        push!(
            datasets,
            OptimizationDataset(
                "chess",
                joinpath(PROJECT_ROOT, "data", "benchmark", "chess.txt"),
                2500,
            ),
        )
    end

    return datasets
end

function csv_bool(value::Bool)::String
    return value ? "true" : "false"
end

function main()
    mkpath(joinpath(PROJECT_ROOT, "outputs", "optimization"))
    mkpath(joinpath(PROJECT_ROOT, "results"))
    mkpath(joinpath(PROJECT_ROOT, "logs"))

    summary_path = joinpath(PROJECT_ROOT, "results", "optimization_summary.csv")
    rows = String["dataset,minsup,itemsets,match,basic_seconds,optimized_seconds,speedup"]
    all_match = true

    println("Running Level 3 optimization comparison...")

    for dataset in selected_datasets()
        isfile(dataset.path) || throw(ArgumentError("missing dataset: $(dataset.path)"))

        db = read_spmf(dataset.path)
        basic_result, basic_time = time_function(() -> prepost_basic(db, dataset.minsup))
        optimized_result, optimized_time = time_function(() -> prepost_optimized(db, dataset.minsup))
        matches = compare_results(basic_result, optimized_result)
        all_match &= matches

        speedup = optimized_time > 0 ? basic_time / optimized_time : Inf
        push!(
            rows,
            join(
                (
                    dataset.name,
                    string(dataset.minsup),
                    string(length(optimized_result)),
                    csv_bool(matches),
                    string(round(basic_time; digits = 6)),
                    string(round(optimized_time; digits = 6)),
                    string(round(speedup; digits = 6)),
                ),
                ",",
            ),
        )
        println(
            dataset.name,
            " minsup=",
            dataset.minsup,
            " itemsets=",
            length(optimized_result),
            " match=",
            matches,
            " basic=",
            round(basic_time; digits = 6),
            "s optimized=",
            round(optimized_time; digits = 6),
            "s speedup=",
            round(speedup; digits = 3),
            "x",
        )
    end

    open(summary_path, "w") do io
        for row in rows
            println(io, row)
        end
    end

    println("Wrote summary: ", summary_path)
    return all_match ? 0 : 1
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    exit(main())
end
