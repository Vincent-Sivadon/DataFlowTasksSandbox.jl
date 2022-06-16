using Plots

"Will produce a grarphtype graph of the function work on context variables"
function logging(work, graphtype, context...)
    # Make a copy of context and Precompile
    # -----------------------------------------
    context_copy = tuple(copy.(context)...)
    work(context_copy...)

    # Clear logger
    # ------------
    DataFlowTasks.clear_logger()
    DataFlowTasks.TASKCOUNTER[] = 0

    # Real Work
    # ---------
    work(context...)

    # Plot
    # ----
    plot(graphtype)
end