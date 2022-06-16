using DataFlowTasks
using DataFlowTasks: R, W, RW
using DataFlowTasksSandbox
using LinearAlgebra

# Environnement
# -------------
DataFlowTasks.should_log() = true
sch = DataFlowTasks.JuliaScheduler(500)
DataFlowTasks.setscheduler!(sch)


# Work
# ----
work(A) = cholesky_dft!(A)


# Context
# -------
DataFlowTasksSandbox.TILESIZE[] = 400
n = 4000
A = rand(n, n)
A = (A + adjoint(A))/2
A = A + n*I


# Logging
# -------
logging(work, TraceLog, A)