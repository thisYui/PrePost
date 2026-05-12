const NListCandidate = Tuple{Int,Vector{NListEntry}}

function mine_recursive!(results::Vector{Tuple{Vector{Int},Int}},
                         prefix_items::Vector{Int},
                         suffix_candidates::Vector{NListCandidate},
                         minsup::Int)
    for i in eachindex(suffix_candidates)
        item, item_nlist = suffix_candidates[i]
        supp = support(item_nlist)
        supp >= minsup || continue

        new_prefix = copy(prefix_items)
        push!(new_prefix, item)
        push!(results, (copy(new_prefix), supp))

        next_candidates = NListCandidate[]
        for j in (i + 1):length(suffix_candidates)
            next_item, next_nlist = suffix_candidates[j]
            joined = join_nlists(item_nlist, next_nlist)
            if support(joined) >= minsup
                push!(next_candidates, (next_item, joined))
            end
        end

        if !isempty(next_candidates)
            mine_recursive!(results, new_prefix, next_candidates, minsup)
        end
    end
    return results
end

function mine_recursive_basic!(results::Vector{Tuple{Vector{Int},Int}},
                               prefix_items::Vector{Int},
                               suffix_candidates::Vector{NListCandidate},
                               minsup::Int)
    for i in eachindex(suffix_candidates)
        item, item_nlist = suffix_candidates[i]
        supp = support(item_nlist)
        supp >= minsup || continue

        new_prefix = copy(prefix_items)
        push!(new_prefix, item)
        push!(results, (copy(new_prefix), supp))

        generated_candidates = NListCandidate[]
        for j in (i + 1):length(suffix_candidates)
            next_item, next_nlist = suffix_candidates[j]
            joined = join_nlists(item_nlist, next_nlist)
            push!(generated_candidates, (next_item, joined))
        end

        next_candidates = NListCandidate[]
        for candidate in generated_candidates
            if support(candidate[2]) >= minsup
                push!(next_candidates, candidate)
            end
        end

        if !isempty(next_candidates)
            mine_recursive_basic!(results, new_prefix, next_candidates, minsup)
        end
    end
    return results
end
