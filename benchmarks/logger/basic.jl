using DataFlowTasksSandbox
using LinearAlgebra
using DataFlowTasks
using DataFlowTasks: R, W, RW
using GraphViz: Graph

# Environnement
# -------------
DataFlowTasks.should_log() = true


# Work
# ----
# Suppose to take ~7ms for A ∈ R^(4000, 4000)
computing(A) = exp.(sum(A).^2).^2
function work(A, B)
    @dspawn computing(A) (A,) (RW,) 0 1
    @dspawn computing(B) (B,) (RW,) 0 2
    @dspawn computing(A) (A,) (RW,) 0 1
    @dspawn computing(B) (B,) (RW,) 0 2
    @dspawn computing(A) (A,) (RW,) 0 1
    @dspawn computing(B) (B,) (RW,) 0 2
    DataFlowTasks.sync()
end


# Context
# -------
A = ones(4000,4000)
B = ones(4000,4000)


# Logging
# -------
set_tracelabels("A", "B")
logging(work, Trace, A, B)