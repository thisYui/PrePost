@testset "Basic vs optimized PrePost" begin
    cases = [
        ("data/toy/example_basic.txt",
         "data/toy/expected/example_basic_minsup2.out",
         2),
        ("data/toy/example_special_single_path.txt",
         "data/toy/expected/example_special_minsup2.out",
         2),
        ("data/toy/example_sparse.txt",
         "data/toy/expected/example_sparse_minsup2.out",
         2),
        ("data/toy/example_with_infrequent_items.txt",
         "data/toy/expected/example_with_infrequent_items_minsup2.out",
         2),
        ("data/toy/example_duplicates_long.txt",
         "data/toy/expected/example_duplicates_long_minsup2.out",
         2),
    ]

    for (input_path, expected_path, minsup) in cases
        db = read_spmf(joinpath(TEST_ROOT, input_path))
        basic_result = prepost_basic(db, minsup)
        optimized_result = prepost_optimized(db, minsup)
        expected = parse_output_file(joinpath(TEST_ROOT, expected_path))

        @test compare_results(basic_result, optimized_result)
        @test compare_results(basic_result, expected)
        @test compare_results(optimized_result, expected)
        @test compare_results(prepost(db, minsup), optimized_result)
    end

    dense_db = TransactionDB([
        [1, 2, 3, 4],
        [1, 2, 3],
        [1, 2, 4],
        [1, 3, 4],
        [2, 3, 4],
    ])
    dense_basic = prepost_basic(dense_db, 3)
    dense_optimized = prepost_optimized(dense_db, 3)

    @test compare_results(dense_basic, dense_optimized)
    @test compare_results(prepost(dense_db, 3), dense_optimized)
end
