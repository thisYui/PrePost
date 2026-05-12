function _lex_less(a::Vector{Int}, b::Vector{Int})::Bool
    for (x, y) in zip(a, b)
        x == y || return x < y
    end
    return length(a) < length(b)
end

function normalize_results(results)::Vector{Tuple{Vector{Int},Int}}
    supports = Dict{Tuple,Int}()
    for (raw_itemset, raw_support) in results
        itemset = sort(Int[item for item in raw_itemset])
        key = Tuple(itemset)
        supp = Int(raw_support)
        if haskey(supports, key) && supports[key] != supp
            throw(ArgumentError("duplicate itemset $(collect(key)) has inconsistent supports"))
        end
        supports[key] = supp
    end

    normalized = Tuple{Vector{Int},Int}[(Int[item for item in key], supp) for (key, supp) in supports]
    sort!(normalized, lt = (a, b) -> begin
        length(a[1]) == length(b[1]) ? _lex_less(a[1], b[1]) : length(a[1]) < length(b[1])
    end)
    return normalized
end

function format_result_line(itemset::Vector{Int}, support::Int)::String
    sorted_items = sort(itemset)
    if isempty(sorted_items)
        return "#SUP: $support"
    end
    return string(join(sorted_items, " "), " #SUP: ", support)
end
