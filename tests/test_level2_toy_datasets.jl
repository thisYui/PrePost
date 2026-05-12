@testset "Level 2 toy datasets" begin
    cases = [
        ("data/toy/example_basic.txt",
         "data/toy/expected/example_basic_minsup2.out",
         2,
         13),

        ("data/toy/example_special_single_path.txt",
         "data/toy/expected/example_special_minsup2.out",
         2,
         15),

        ("data/toy/example_sparse.txt",
         "data/toy/expected/example_sparse_minsup2.out",
         2,
         5),

        ("data/toy/example_with_infrequent_items.txt",
         "data/toy/expected/example_with_infrequent_items_minsup2.out",
         2,
         6),

        ("data/toy/example_duplicates_long.txt",
         "data/toy/expected/example_duplicates_long_minsup2.out",
         2,
         15),
    ]

    for (input_path, expected_path, minsup, expected_count) in cases
        db = read_spmf(joinpath(TEST_ROOT, input_path))
        actual = prepost(db, minsup)
        expected = parse_output_file(joinpath(TEST_ROOT, expected_path))

        @test length(actual) == expected_count
        @test compare_results(actual, expected)
    end
end
