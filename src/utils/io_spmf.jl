function read_spmf(path::AbstractString)::TransactionDB
    transactions = Vector{Int}[]
    open(path, "r") do io
        for raw_line in eachline(io)
            line = split(raw_line, '#'; limit = 2)[1]
            line = strip(line)
            isempty(line) && continue
            push!(transactions, parse.(Int, split(line)))
        end
    end
    return TransactionDB(transactions)
end

function write_spmf_output(path::AbstractString, results)
    normalized = normalize_results(results)
    open(path, "w") do io
        for (itemset, supp) in normalized
            println(io, format_result_line(itemset, supp))
        end
    end
    return path
end
