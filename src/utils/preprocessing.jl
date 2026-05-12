function count_single_items(db::TransactionDB)::Dict{Int,Int}
    counts = Dict{Int,Int}()
    for transaction in db.transactions
        seen = Set{Int}()
        for item in transaction
            if !(item in seen)
                counts[item] = get(counts, item, 0) + 1
                push!(seen, item)
            end
        end
    end
    return counts
end

function filter_frequent_items(counts::Dict{Int,Int}, minsup::Int)::Dict{Int,Int}
    frequent = Dict{Int,Int}()
    for (item, count) in counts
        if count >= minsup
            frequent[item] = count
        end
    end
    return frequent
end

function global_order(frequent_counts::Dict{Int,Int})
    order = collect(keys(frequent_counts))
    sort!(order, by = item -> (-frequent_counts[item], item))
    rank = Dict{Int,Int}(item => index for (index, item) in pairs(order))
    return order, rank
end

function sort_and_filter_transactions(db::TransactionDB,
                                      frequent_counts::Dict{Int,Int},
                                      order)
    rank = order isa Tuple ? order[2] : Dict{Int,Int}(item => index for (index, item) in pairs(order))
    transactions = Vector{Int}[]
    for transaction in db.transactions
        filtered = Int[]
        seen = Set{Int}()
        for item in transaction
            if haskey(frequent_counts, item) && !(item in seen)
                push!(filtered, item)
                push!(seen, item)
            end
        end
        sort!(filtered, by = item -> rank[item])
        if !isempty(filtered)
            push!(transactions, filtered)
        end
    end
    return TransactionDB(transactions)
end
