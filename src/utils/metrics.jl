function parse_output_file(path::AbstractString)::Vector{Tuple{Vector{Int},Int}}
    results = Tuple{Vector{Int},Int}[]
    open(path, "r") do io
        for raw_line in eachline(io)
            line = strip(raw_line)
            isempty(line) && continue
            parts = split(line, "#SUP:"; limit = 2)
            length(parts) == 2 || throw(ArgumentError("invalid output line: $raw_line"))
            item_part = strip(parts[1])
            support_part = strip(parts[2])
            itemset = isempty(item_part) ? Int[] : parse.(Int, split(item_part))
            supp = parse(Int, support_part)
            push!(results, (itemset, supp))
        end
    end
    return normalize_results(results)
end

function result_set(results)
    normalized = normalize_results(results)
    return Set((Tuple(itemset), supp) for (itemset, supp) in normalized)
end

compare_results(actual, expected)::Bool = result_set(actual) == result_set(expected)
