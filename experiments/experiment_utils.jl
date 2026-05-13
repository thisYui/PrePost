using CSV
using DataFrames
using PrePostFIM

include("config.jl")

const ALGORITHMS = ("basic", "optimized")

function dataset_exists(dataset)::Bool
    return isfile(dataset.path)
end

function output_name(dataset_name::AbstractString, algorithm::AbstractString, minsup::Integer)::String
    return "$(dataset_name)_$(algorithm)_minsup$(minsup).out"
end

function spmf_output_name(dataset_name::AbstractString, minsup::Integer)::String
    return output_name(dataset_name, "spmf", minsup)
end

function minsup_ratio(minsup::Integer, transactions::Integer)::Float64
    transactions <= 0 && return NaN
    return minsup / transactions
end

function spmf_minsup_parameter(minsup::Integer, transactions::Integer)::String
    transactions > 0 || throw(ArgumentError("transactions must be positive for SPMF minsup conversion"))
    return string(((minsup - 1.0e-6) / transactions) * 100.0, "%")
end

function mine_with_algorithm(db::TransactionDB, algorithm::AbstractString, minsup::Integer)
    if algorithm == "basic"
        return time_function(() -> prepost_basic(db, minsup))
    elseif algorithm == "optimized"
        return time_function(() -> prepost_optimized(db, minsup))
    end
    throw(ArgumentError("unknown algorithm: $algorithm"))
end

function run_our(dataset, algorithm::AbstractString, minsup::Integer)
    out_path = joinpath(OUR_OUTPUT_DIR, output_name(dataset.name, algorithm, minsup))
    if !dataset_exists(dataset)
        return (status = "MISSING_DATASET", output_file = out_path, itemsets = 0, elapsed_seconds = NaN)
    end

    try
        db = read_spmf(dataset.path)
        results, elapsed = mine_with_algorithm(db, algorithm, minsup)
        write_spmf_output(out_path, results)
        return (status = "OK", output_file = out_path, itemsets = length(results), elapsed_seconds = elapsed)
    catch err
        @warn "Mining failed" dataset = dataset.name algorithm minsup err
        return (status = "ERROR: $(sprint(showerror, err))", output_file = out_path, itemsets = 0, elapsed_seconds = NaN)
    end
end

function run_spmf(dataset, minsup::Integer)
    out_path = joinpath(SPMF_OUTPUT_DIR, spmf_output_name(dataset.name, minsup))
    jar = spmf_jar_path()
    if !dataset_exists(dataset)
        return (status = "MISSING_DATASET", output_file = out_path, itemsets = 0, elapsed_seconds = NaN)
    elseif !isfile(jar)
        return (status = "MISSING_SPMF_JAR: $jar", output_file = out_path, itemsets = 0, elapsed_seconds = NaN)
    end

    try
        mkpath(dirname(out_path))
        spmf_minsup = spmf_minsup_parameter(minsup, dataset.num_transactions)
        elapsed = @elapsed run(`java -jar $jar run PrePost $(dataset.path) $out_path $spmf_minsup`)
        itemsets = isfile(out_path) ? length(parse_output_file(out_path)) : 0
        return (status = "OK", output_file = out_path, itemsets = itemsets, elapsed_seconds = elapsed)
    catch err
        @warn "SPMF failed" dataset = dataset.name minsup err
        return (status = "ERROR: $(sprint(showerror, err))", output_file = out_path, itemsets = 0, elapsed_seconds = NaN)
    end
end

function write_csv(path::AbstractString, rows)
    mkpath(dirname(path))
    CSV.write(path, DataFrame(rows))
    return path
end

function itemset_support_map(results)
    return Dict(Tuple(itemset) => supp for (itemset, supp) in normalize_results(results))
end

function mismatch_rows(dataset_name::AbstractString, minsup::Integer, our_results, spmf_results)
    our = itemset_support_map(our_results)
    spmf = itemset_support_map(spmf_results)
    keys_all = sort(collect(union(keys(our), keys(spmf))), by = x -> (length(x), join(collect(x), " ")))
    rows = NamedTuple[]
    for key in keys_all
        our_supp = get(our, key, missing)
        spmf_supp = get(spmf, key, missing)
        if ismissing(our_supp) || ismissing(spmf_supp) || our_supp != spmf_supp
            issue = ismissing(our_supp) ? "missing_in_our" :
                    ismissing(spmf_supp) ? "extra_in_our" : "support_mismatch"
            push!(rows, (
                dataset = dataset_name,
                minsup = minsup,
                itemset = join(collect(key), " "),
                our_support = our_supp,
                spmf_support = spmf_supp,
                issue = issue,
            ))
        end
    end
    return rows
end

function parse_existing_count(path::AbstractString)::Int
    return isfile(path) ? length(parse_output_file(path)) : 0
end
