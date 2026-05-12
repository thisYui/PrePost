function time_function(f)::Tuple{Any,Float64}
    start = time()
    result = f()
    elapsed = time() - start
    return result, elapsed
end
