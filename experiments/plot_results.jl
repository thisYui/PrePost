using CSV
using DataFrames
using Plots
using StatsPlots

include("config.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)
const SELECTED_DATASETS = PARSED_ARGS["datasets"]

function filter_selected(df::DataFrame, datasets)
    isempty(df) && return df
    "dataset" in names(df) || return df
    names_set = Set(dataset.name for dataset in datasets)
    return df[in.(df.dataset, Ref(names_set)), :]
end

function read_if_exists(name::AbstractString)
    path = joinpath(CSV_OUTPUT_DIR, name)
    return isfile(path) ? CSV.read(path, DataFrame) : DataFrame()
end

function save_runtime_plots(runtime_df::DataFrame)
    isempty(runtime_df) && return
    for dataset in unique(runtime_df.dataset)
        df = runtime_df[runtime_df.dataset .== dataset, :]
        p = plot(title = "Runtime vs minsup ($dataset)", xlabel = "minsup", ylabel = "elapsed ms",
                 marker = :circle, legend = :topright, xflip = true)
        for algorithm in unique(df.algorithm)
            sub = sort(df[df.algorithm .== algorithm, :], :minsup)
            plot!(p, sub.minsup, sub.elapsed_ms, label = string(algorithm), marker = :circle)
        end
        savefig(p, joinpath(FIGURE_OUTPUT_DIR, "runtime_$(dataset).png"))
    end
end

function save_output_size_plots(size_df::DataFrame)
    isempty(size_df) && return
    for dataset in unique(size_df.dataset)
        df = size_df[size_df.dataset .== dataset, :]
        p = plot(title = "Frequent itemsets vs minsup ($dataset)", xlabel = "minsup",
                 ylabel = "frequent itemsets", marker = :circle, legend = :topright, xflip = true)
        for algorithm in unique(df.algorithm)
            sub = sort(df[df.algorithm .== algorithm, :], :minsup)
            plot!(p, sub.minsup, sub.itemsets, label = string(algorithm), marker = :circle)
        end
        savefig(p, joinpath(FIGURE_OUTPUT_DIR, "output_size_$(dataset).png"))
    end
end

function save_memory_plot(memory_df::DataFrame)
    isempty(memory_df) && return
    df = filter(row -> row.status != "MISSING_DATASET", memory_df)
    isempty(df) && return
    p = groupedbar(string.(df.dataset), df.allocated_mb, group = string.(df.algorithm),
                   title = "Allocated memory at medium minsup", xlabel = "dataset",
                   ylabel = "allocated MB", legend = :topright, xrotation = 30)
    savefig(p, joinpath(FIGURE_OUTPUT_DIR, "memory_usage.png"))
end

function save_scalability_plot(scalability_df::DataFrame)
    isempty(scalability_df) && return
    p = plot(title = "Scalability", xlabel = "transactions (%)", ylabel = "elapsed ms",
             marker = :circle, legend = :topleft)
    for algorithm in unique(scalability_df.algorithm)
        sub = sort(scalability_df[scalability_df.algorithm .== algorithm, :], :subset_ratio)
        plot!(p, sub.subset_ratio .* 100, sub.elapsed_ms, label = string(algorithm), marker = :circle)
    end
    savefig(p, joinpath(FIGURE_OUTPUT_DIR, "scalability.png"))
end

function save_transaction_length_plot(length_df::DataFrame)
    isempty(length_df) && return
    df = sort(length_df, :avg_len)
    p = plot(df.avg_len, df.elapsed_ms, title = "Runtime vs average transaction length",
             xlabel = "average transaction length", ylabel = "elapsed ms",
             label = "optimized", marker = :circle, legend = :topleft)
    savefig(p, joinpath(FIGURE_OUTPUT_DIR, "transaction_length.png"))
end

function plot_results(datasets)
    ensure_dirs()
    save_runtime_plots(filter_selected(read_if_exists("runtime_minsup.csv"), datasets))
    save_output_size_plots(filter_selected(read_if_exists("output_size.csv"), datasets))
    save_memory_plot(filter_selected(read_if_exists("memory_usage.csv"), datasets))
    save_scalability_plot(filter_selected(read_if_exists("scalability.csv"), datasets))
    save_transaction_length_plot(read_if_exists("transaction_length.csv"))
    println("wrote figures to $FIGURE_OUTPUT_DIR")
end

plot_results(selected_dataset_configs(DATASETS, SELECTED_DATASETS))
