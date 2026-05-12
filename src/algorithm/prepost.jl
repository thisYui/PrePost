function _prepost_candidates(db::TransactionDB, minsup::Int)::Vector{NListCandidate}
    minsup > 0 || throw(ArgumentError("minsup must be a positive integer"))
    isempty(db.transactions) && return NListCandidate[]

    counts = count_single_items(db)
    frequent_counts = filter_frequent_items(counts, minsup)
    isempty(frequent_counts) && return NListCandidate[]

    order, rank = global_order(frequent_counts)
    filtered_db = sort_and_filter_transactions(db, frequent_counts, (order, rank))

    tree = PPCTree()
    for transaction in filtered_db.transactions
        insert_transaction!(tree, transaction)
    end
    assign_pre_post!(tree)

    single_nlists = build_single_nlists(tree)
    candidates = NListCandidate[]
    for item in order
        nlist = get(single_nlists, item, NListEntry[])
        if support(nlist) >= minsup
            push!(candidates, (item, nlist))
        end
    end

    return candidates
end

function prepost_basic(db::TransactionDB, minsup::Int)::Vector{Tuple{Vector{Int},Int}}
    candidates = _prepost_candidates(db, minsup)
    results = Tuple{Vector{Int},Int}[]
    mine_recursive_basic!(results, Int[], candidates, minsup)
    return normalize_results(results)
end

function prepost_optimized(db::TransactionDB, minsup::Int)::Vector{Tuple{Vector{Int},Int}}
    candidates = _prepost_candidates(db, minsup)
    results = Tuple{Vector{Int},Int}[]
    mine_recursive!(results, Int[], candidates, minsup)
    return normalize_results(results)
end

prepost(db::TransactionDB, minsup::Int)::Vector{Tuple{Vector{Int},Int}} = prepost_optimized(db, minsup)
