@testset "SPMF I/O" begin
    basic_path = joinpath(TEST_ROOT, "data", "toy", "example_basic.txt")
    db = read_spmf(basic_path)

    @test length(db.transactions) == 5
    @test db.transactions[1] == [1, 2, 3]

    expected_results = Tuple{Vector{Int},Int}[
        ([3, 1], 3),
        ([2], 4),
        ([1], 3),
        ([1, 2, 3], 2),
    ]

    mktemp() do path, _
        write_spmf_output(path, expected_results)
        parsed = parse_output_file(path)
        @test compare_results(parsed, normalize_results(expected_results))
        @test parsed == normalize_results(expected_results)
    end

    mktemp() do path, io
        write(io, "\n")
        write(io, "1 2 3 # trailing comment\n")
        write(io, "   \n")
        write(io, "4 5\n")
        write(io, "# full line comment\n")
        write(io, "6   7   8   # another comment\n")
        close(io)

        commented_db = read_spmf(path)
        @test commented_db.transactions == [[1, 2, 3], [4, 5], [6, 7, 8]]
    end
end
