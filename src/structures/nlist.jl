struct NListEntry
    pre::Int
    post::Int
    count::Int
end

function support(nlist::Vector{NListEntry})::Int
    total = 0
    for entry in nlist
        total += entry.count
    end
    return total
end

function build_single_nlists(tree::PPCTree)::Dict{Int,Vector{NListEntry}}
    nlists = Dict{Int,Vector{NListEntry}}()
    for node in collect_nodes(tree)
        item = node.item::Int
        entries = get!(nlists, item, NListEntry[])
        push!(entries, NListEntry(node.pre, node.post, node.count))
    end
    for entries in values(nlists)
        sort!(entries, by = entry -> entry.pre)
    end
    return nlists
end

function join_nlists(prefix_nlist::Vector{NListEntry},
                     extension_nlist::Vector{NListEntry})::Vector{NListEntry}
    joined = NListEntry[]
    used = Set{Tuple{Int,Int,Int}}()
    for y in extension_nlist
        for x in prefix_nlist
            if x.pre < y.pre && x.post > y.post
                key = (y.pre, y.post, y.count)
                if !(key in used)
                    push!(joined, y)
                    push!(used, key)
                end
                break
            end
        end
    end
    sort!(joined, by = entry -> entry.pre)
    return joined
end
