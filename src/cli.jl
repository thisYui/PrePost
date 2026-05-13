using PrePostFIM

function usage()
    println("Usage: julia --project=. src/cli.jl --input <path> --minsup <integer> [--algorithm basic|optimized] --output <path>")
end

function parse_args(args::Vector{String})
    parsed = Dict{String,String}()
    i = 1
    while i <= length(args)
        arg = args[i]
        if arg in ("--input", "--minsup", "--output", "--algorithm")
            if i == length(args)
                throw(ArgumentError("missing value for $arg"))
            end
            parsed[arg] = args[i + 1]
            i += 2
        else
            throw(ArgumentError("unknown argument: $arg"))
        end
    end
    return parsed
end

function main(args::Vector{String})
    parsed = parse_args(args)
    required = ("--input", "--minsup", "--output")
    if any(arg -> !haskey(parsed, arg), required)
        usage()
        return 1
    end

    input_path = parsed["--input"]
    output_path = parsed["--output"]
    minsup = parse(Int, parsed["--minsup"])
    algorithm = get(parsed, "--algorithm", "optimized")
    algorithm in ("basic", "optimized") || throw(ArgumentError("--algorithm must be basic or optimized"))

    db = read_spmf(input_path)
    miner = algorithm == "basic" ? prepost_basic : prepost_optimized
    results, elapsed = time_function(() -> miner(db, minsup))
    output_dir = dirname(output_path)
    !isempty(output_dir) && mkpath(output_dir)
    write_spmf_output(output_path, results)

    println("Input: $input_path")
    println("Output: $output_path")
    println("minsup: $minsup")
    println("Algorithm: $algorithm")
    println("Frequent itemsets: $(length(results))")
    println("Elapsed time: $(round(elapsed; digits = 6)) seconds")
    return 0
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    try
        exit(main(ARGS))
    catch err
        usage()
        println(stderr, err)
        exit(1)
    end
end
