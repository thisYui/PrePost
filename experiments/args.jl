function split_csv_values(value::AbstractString)::Vector{String}
    return [strip(part) for part in split(value, ",") if !isempty(strip(part))]
end

function parse_experiment_args(args::Vector{String})::Dict{String,Any}
    parsed = Dict{String,Any}(
        "spmf" => false,
        "datasets" => String[],
        "experiments" => String[],
    )

    i = 1
    while i <= length(args)
        arg = args[i]
        if arg == "--spmf"
            parsed["spmf"] = true
            i += 1
        elseif arg == "--datasets"
            i == length(args) && throw(ArgumentError("missing value for --datasets"))
            parsed["datasets"] = split_csv_values(args[i + 1])
            i += 2
        elseif arg == "--experiments"
            i == length(args) && throw(ArgumentError("missing value for --experiments"))
            parsed["experiments"] = split_csv_values(args[i + 1])
            i += 2
        else
            throw(ArgumentError("unknown argument: $arg"))
        end
    end

    return parsed
end

function selected_dataset_configs(datasets, selected_names)
    isempty(selected_names) && return collect(datasets)

    by_name = Dict(dataset.name => dataset for dataset in datasets)
    available = join(sort(collect(keys(by_name))), ", ")
    selected = eltype(collect(datasets))[]
    for name in selected_names
        if !haskey(by_name, name)
            throw(ArgumentError("unknown dataset: $name. Available datasets: $available"))
        end
        push!(selected, by_name[name])
    end
    return selected
end
