@testset "N-list" begin
    tree = build_basic_ppc_tree()
    nlists = build_single_nlists(tree)

    @test support(nlists[3]) == 5
    @test support(nlists[2]) == 4
    @test support(nlists[1]) == 3
    @test support(nlists[4]) == 2
    @test support(nlists[5]) == 2

    joined_32 = join_nlists(nlists[3], nlists[2])
    joined_31 = join_nlists(nlists[3], nlists[1])
    joined_25 = join_nlists(nlists[2], nlists[5])

    @test support(joined_32) == 4
    @test support(joined_31) == 3
    @test support(joined_25) == 2

    duplicate_join = join_nlists([nlists[3][1], nlists[3][1]], nlists[2])
    @test support(duplicate_join) == 4
    @test length(duplicate_join) == length(unique(entry -> (entry.pre, entry.post, entry.count), duplicate_join))
end
