struct TransactionDB
    transactions::Vector{Vector{Int}}
end

num_transactions(db::TransactionDB)::Int = length(db.transactions)

function num_items(db::TransactionDB)::Int
    items = Set{Int}()
    for transaction in db.transactions
        union!(items, transaction)
    end
    return length(items)
end

function avg_transaction_length(db::TransactionDB)::Float64
    isempty(db.transactions) && return 0.0
    total = 0
    for transaction in db.transactions
        total += length(transaction)
    end
    return total / length(db.transactions)
end
