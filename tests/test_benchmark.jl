@testset "Benchmark smoke checks" begin
    benchmark_files = [
        joinpath(TEST_ROOT, "data", "benchmark", "chess.txt"),
        joinpath(TEST_ROOT, "data", "benchmark", "mushroom.txt"),
        joinpath(TEST_ROOT, "data", "benchmark", "retail.txt"),
        joinpath(TEST_ROOT, "data", "benchmark", "T10I4D100K.txt"),
    ]

    subset_files = [
        joinpath(TEST_ROOT, "data", "subsets", "retail_10.txt"),
        joinpath(TEST_ROOT, "data", "subsets", "retail_25.txt"),
        joinpath(TEST_ROOT, "data", "subsets", "retail_50.txt"),
        joinpath(TEST_ROOT, "data", "subsets", "retail_75.txt"),
        joinpath(TEST_ROOT, "data", "subsets", "retail_100.txt"),
    ]

    application_file = joinpath(TEST_ROOT, "data", "application", "groceries.txt")

    for path in vcat(benchmark_files, subset_files, [application_file])
        @test isfile(path)
    end

    tiny_db = TransactionDB([[1, 2], [1, 3], [1, 2, 3]])
    result, elapsed = time_function(() -> prepost(tiny_db, 2))

    @test elapsed >= 0.0
    @test compare_results(result, [([1], 3), ([2], 2), ([3], 2), ([1, 2], 2), ([1, 3], 2)])
end
