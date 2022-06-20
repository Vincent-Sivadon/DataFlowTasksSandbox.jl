using DataFlowTasks
using DataFlowTasks: R, W, RW
using LinearAlgebra
using DataFlowTasksSandbox
using GraphViz: Graph

# Desactivate plotting if it is a server
servers = ["maury", "muscat", "maranges"]
current = gethostname()
is_server = isempty(findall(str -> str == current, servers))
if (is_server)
    ENV["GKSwstype"]="nul"
end

DataFlowTasks.should_log() = true
sch = DataFlowTasks.JuliaScheduler(500)
DataFlowTasks.setscheduler!(sch)

# Work
# ----
work(A) = cholesky_dft!(A)

# Context
# -------
nthreads = Threads.nthreads()
tilesizes = 256
DataFlowTasksSandbox.TILESIZE[] = tilesizes
n = 2048
A = rand(n, n)
A = (A + adjoint(A))/2
A = A + n*I

set_tracelabels("chol", "ldiv", "schur")
g = logging(work, Trace, A)

# Decomment to save DAG svg file
# ------------------------------
# io = open("./fig/logger/dag.svg", "w")
# GraphViz.render(io, g)

# Decomment to save TRACE png file
# ------------------------------
# using Plots
# machine = gethostname()
# savefig("./fig/logger/cholesky_$(machine)_$(n)_$(tilesizes)_$nthreads.png")