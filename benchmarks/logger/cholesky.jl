using DataFlowTasks
using DataFlowTasks: R, W, RW
using LinearAlgebra
using DataFlowTasksSandbox

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


logging(work, TraceLog, A)