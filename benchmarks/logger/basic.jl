using DataFlowTasksSandbox
using LinearAlgebra
using DataFlowTasks
using DataFlowTasks: R, W, RW

# Environnement
# -------------
DataFlowTasks.should_log() = true

# Work
# ----
# Suppose to take ~7ms for A ∈ R^(4000, 4000)
computing(A) = exp.(sum(A).^2).^2
function work(A, B)
    @dspawn computing(A) (A,) (RW,)
    @dspawn computing(B) (B,) (RW,) 
    @dspawn computing(A) (A,) (RW,)
    @dspawn computing(B) (B,) (RW,)
    @dspawn computing(A) (A,) (RW,)
    @dspawn computing(B) (B,) (RW,)
    DataFlowTasks.sync()
end

# Context
# -------
const A = ones(2000,2000)
const B = ones(2000,2000)

# Logging
# -------
logging(work, TraceLog, A, B)