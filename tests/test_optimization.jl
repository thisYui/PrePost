@testset "Basic vs optimized PrePost" begin
    basic_input = joinpath(TEST_ROOT, "data", "toy", "example_basic.txt")
    basic_expected = joinpath(TEST_ROOT, "data", "toy", "expected", "example_basic_minsup2.out")
    basic_db = read_spmf(basic_input)
    basic_result = prepost_basic(basic_db, 2)
    optimized_result = prepost_optimized(basic_db, 2)
    expected_basic = parse_output_file(basic_expected)

    @test compare_results(basic_result, optimized_result)
    @test compare_results(basic_result, expected_basic)
    @test compare_results(optimized_result, expected_basic)
    @test compare_results(prepost(basic_db, 2), optimized_result)

    special_input = joinpath(TEST_ROOT, "data", "toy", "example_special_single_path.txt")
    special_expected = joinpath(TEST_ROOT, "data", "toy", "expected", "example_special_minsup2.out")
    special_db = read_spmf(special_input)
    special_basic = prepost_basic(special_db, 2)
    special_optimized = prepost_optimized(special_db, 2)
    expected_special = parse_output_file(special_expected)

    @test compare_results(special_basic, special_optimized)
    @test compare_results(special_basic, expected_special)
    @test compare_results(special_optimized, expected_special)
    @test compare_results(prepost(special_db, 2), special_optimized)

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
