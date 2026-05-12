@testset "PrePost correctness" begin
    basic_input = joinpath(TEST_ROOT, "data", "toy", "example_basic.txt")
    basic_expected = joinpath(TEST_ROOT, "data", "toy", "expected", "example_basic_minsup2.out")
    basic_results = prepost(read_spmf(basic_input), 2)
    @test compare_results(basic_results, parse_output_file(basic_expected))

    special_input = joinpath(TEST_ROOT, "data", "toy", "example_special_single_path.txt")
    special_expected = joinpath(TEST_ROOT, "data", "toy", "expected", "example_special_minsup2.out")
    special_results = prepost(read_spmf(special_input), 2)
    @test compare_results(special_results, parse_output_file(special_expected))

    @test prepost(TransactionDB(Vector{Int}[]), 1) == Tuple{Vector{Int},Int}[]

    single_transaction_results = prepost(TransactionDB([[1, 2, 3]]), 1)
    single_transaction_expected = Tuple{Vector{Int},Int}[
        ([1], 1),
        ([2], 1),
        ([3], 1),
        ([1, 2], 1),
        ([1, 3], 1),
        ([2, 3], 1),
        ([1, 2, 3], 1),
    ]
    @test compare_results(single_transaction_results, single_transaction_expected)
    @test length(single_transaction_results) == 7

    shared_item_results = prepost(TransactionDB([[1, 2], [1, 3], [1, 4]]), 2)
    @test shared_item_results == [([1], 3)]

    @test_throws ArgumentError prepost(TransactionDB([[1, 2, 3]]), 0)
    @test_throws ArgumentError prepost(TransactionDB([[1, 2, 3]]), -1)
end
