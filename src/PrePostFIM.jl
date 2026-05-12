module PrePostFIM

include("structures/transaction_db.jl")
include("structures/ppc_tree.jl")
include("structures/nlist.jl")
include("utils/preprocessing.jl")
include("utils/io_spmf.jl")
include("utils/metrics.jl")
include("utils/timer.jl")
include("algorithm/output.jl")
include("algorithm/mining.jl")
include("algorithm/prepost.jl")

export TransactionDB,
       num_transactions,
       num_items,
       avg_transaction_length,
       read_spmf,
       write_spmf_output,
       prepost,
       prepost_basic,
       prepost_optimized,
       normalize_results,
       format_result_line,
       parse_output_file,
       result_set,
       compare_results,
       PPCTree,
       PPCNode,
       insert_transaction!,
       assign_pre_post!,
       collect_nodes,
       NListEntry,
       support,
       build_single_nlists,
       join_nlists,
       count_single_items,
       filter_frequent_items,
       global_order,
       sort_and_filter_transactions,
       time_function

end
