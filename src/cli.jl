using PrePostFIM

function usage()
    println("Usage: julia --project=. src/cli.jl --input <path> --minsup <integer> --output <path>")
end

function parse_args(args::Vector{String})
    parsed = Dict{String,String}()
    i = 1
    while i <= length(args)
        arg = args[i]
        if arg in ("--input", "--minsup", "--output")
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

    db = read_spmf(input_path)
    results, elapsed = time_function(() -> prepost(db, minsup))
    write_spmf_output(output_path, results)

    println("Input: $input_path")
    println("Output: $output_path")
    println("minsup: $minsup")
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
