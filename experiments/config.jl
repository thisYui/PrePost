const PROJECT_ROOT = normpath(joinpath(@__DIR__, ".."))

const OUTPUT_ROOT = joinpath(PROJECT_ROOT, "outputs")
const OUR_OUTPUT_DIR = joinpath(OUTPUT_ROOT, "our")
const SPMF_OUTPUT_DIR = joinpath(OUTPUT_ROOT, "spmf")
const CSV_OUTPUT_DIR = joinpath(OUTPUT_ROOT, "csv")
const FIGURE_OUTPUT_DIR = joinpath(OUTPUT_ROOT, "figures")
const SPMF_JAR = joinpath(PROJECT_ROOT, "tools", "spmf.jar")
const FALLBACK_SPMF_JAR = joinpath(PROJECT_ROOT, "spmf", "spmf.jar")

Base.@kwdef struct DatasetConfig
    name::String
    path::String
    num_transactions::Int
    minsups::Vector{Int}
    medium_minsup::Int
end

const DATASETS = DatasetConfig[
    DatasetConfig(
        name = "chess",
        path = joinpath(PROJECT_ROOT, "data", "benchmark", "chess.txt"),
        num_transactions = 3196,
        minsups = [2558, 2397, 2237, 2077, 1918, 1758],
        medium_minsup = 2077,
    ),
    DatasetConfig(
        name = "mushroom",
        path = joinpath(PROJECT_ROOT, "data", "benchmark", "mushroom.txt"),
        num_transactions = 8124,
        minsups = [4062, 3656, 3249, 2843, 2437, 2031],
        medium_minsup = 2437,
    ),
    DatasetConfig(
        name = "retail",
        path = joinpath(PROJECT_ROOT, "data", "benchmark", "retail.txt"),
        num_transactions = 88162,
        minsups = [1763, 1322, 882, 661, 441, 220],
        medium_minsup = 661,
    ),
    DatasetConfig(
        name = "T10I4D100K",
        path = joinpath(PROJECT_ROOT, "data", "benchmark", "T10I4D100K.txt"),
        num_transactions = 100000,
        minsups = [2000, 1500, 1000, 750, 500, 250],
        medium_minsup = 750,
    ),
]

function ensure_dirs()
    for dir in (OUR_OUTPUT_DIR, SPMF_OUTPUT_DIR, CSV_OUTPUT_DIR, FIGURE_OUTPUT_DIR)
        mkpath(dir)
    end
end

function spmf_jar_path()
    return isfile(SPMF_JAR) ? SPMF_JAR : FALLBACK_SPMF_JAR
end
