function basic_sorted_transactions()
    return Vector{Int}[
        [3, 2, 1],
        [3, 1, 4],
        [3, 2, 5],
        [3, 2, 1, 5],
        [3, 2, 4],
    ]
end

function build_basic_ppc_tree()
    tree = PPCTree()
    for transaction in basic_sorted_transactions()
        insert_transaction!(tree, transaction)
    end
    assign_pre_post!(tree)
    return tree
end

@testset "PPC-tree" begin
    tree = build_basic_ppc_tree()
    nodes = collect_nodes(tree)

    @test length(nodes) == 8

    counts = Dict{Int,Int}()
    for node in nodes
        counts[node.item] = get(counts, node.item, 0) + node.count
    end

    @test counts[3] == 5
    @test counts[2] == 4
    @test counts[1] == 3
    @test counts[4] == 2
    @test counts[5] == 2

    for node in nodes
        @test node.pre > 0
        @test node.post > 0
        if node.parent !== nothing && node.parent.item !== nothing
            @test node.parent.pre < node.pre
            @test node.parent.post > node.post
        end
    end
end
