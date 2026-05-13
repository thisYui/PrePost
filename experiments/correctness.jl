using CSV
using DataFrames

include("experiment_utils.jl")
include("args.jl")

const PARSED_ARGS = parse_experiment_args(ARGS)
const RUN_SPMF = PARSED_ARGS["spmf"]
const SELECTED_DATASETS = PARSED_ARGS["datasets"]

function correctness_reference(dataset, minsup::Integer)
    if RUN_SPMF
        return run_spmf(dataset, minsup)
    end

    out_path = joinpath(SPMF_OUTPUT_DIR, spmf_output_name(dataset.name, minsup))
    if isfile(out_path)
        itemsets = length(parse_output_file(out_path))
        return (status = "OK", output_file = out_path, itemsets = itemsets, elapsed_seconds = NaN)
    end
    return (status = "SKIPPED_REFERENCE_NOT_FOUND", output_file = out_path, itemsets = 0, elapsed_seconds = NaN)
end

function run_correctness(datasets)
    ensure_dirs()
    rows = NamedTuple[]

    for dataset in datasets
        minsup = dataset.medium_minsup
        println("correctness: $(dataset.name), minsup=$minsup")
        our_run = run_our(dataset, "optimized", minsup)
        spmf_run = correctness_reference(dataset, minsup)

        if our_run.status == "OK" && spmf_run.status == "OK"
            our_results = parse_output_file(our_run.output_file)
            spmf_results = parse_output_file(spmf_run.output_file)
            mismatches = mismatch_rows(dataset.name, minsup, our_results, spmf_results)
            support_mismatch = count(row -> row.issue == "support_mismatch", mismatches)
            missing_in_our = count(row -> row.issue == "missing_in_our", mismatches)
            extra_in_our = count(row -> row.issue == "extra_in_our", mismatches)
            matched_itemsets = length(our_results) - extra_in_our - support_mismatch
            match_ratio_value = isempty(spmf_results) ? 1.0 : matched_itemsets / length(spmf_results)
            status = isempty(mismatches) ? "PASS" : "FAIL"

            if !isempty(mismatches)
                detail_path = joinpath(CSV_OUTPUT_DIR, "correctness_mismatches_$(dataset.name)_$(minsup).csv")
                write_csv(detail_path, mismatches)
            end

            push!(rows, (
                dataset = dataset.name,
                minsup = minsup,
                our_itemsets = length(our_results),
                spmf_itemsets = length(spmf_results),
                matched_itemsets = matched_itemsets,
                missing_in_our = missing_in_our,
                extra_in_our = extra_in_our,
                support_mismatch = support_mismatch,
                match_ratio = match_ratio_value,
                status = status,
            ))
        else
            push!(rows, (
                dataset = dataset.name,
                minsup = minsup,
                our_itemsets = our_run.itemsets,
                spmf_itemsets = spmf_run.itemsets,
                matched_itemsets = 0,
                missing_in_our = 0,
                extra_in_our = 0,
                support_mismatch = 0,
                match_ratio = NaN,
                status = RUN_SPMF ? "SKIP: our=$(our_run.status); spmf=$(spmf_run.status)" :
                         spmf_run.status == "SKIPPED_REFERENCE_NOT_FOUND" ? "SKIPPED_REFERENCE_NOT_FOUND" :
                         "SKIPPED_SPMF_DISABLED: our=$(our_run.status); reference=$(spmf_run.status)",
            ))
        end
    end

    path = joinpath(CSV_OUTPUT_DIR, "correctness.csv")
    write_csv(path, rows)
    println("wrote $path")
end

run_correctness(selected_dataset_configs(DATASETS, SELECTED_DATASETS))
