using Test
using PrePostFIM

const TEST_ROOT = dirname(@__DIR__)

println("Starting PrePostFIM test suite...")

@testset "PrePostFIM" begin
    include("test_io.jl")
    include("test_ppc_tree.jl")
    include("test_nlist.jl")
    include("test_correctness.jl")
    include("test_level2_toy_datasets.jl")
    include("test_optimization.jl")
    include("test_benchmark.jl")
end

println("Finished PrePostFIM test suite.")
