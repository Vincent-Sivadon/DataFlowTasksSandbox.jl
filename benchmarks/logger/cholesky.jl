using DataFlowTasks
using DataFlowTasks: R, W, RW
using LinearAlgebra
using DataFlowTasksSandbox
using GraphViz
using GraphViz: Graph

# Desactivate plotting if it is a server
# --------------------------------------
servers = ["maury", "muscat", "maranges"]
current = gethostname()
is_server = isempty(findall(str -> str == current, servers))
if (is_server)
    ENV["GKSwstype"]="nul"
end
# --------------------------------------


# DataFlowTasks Environnement
DataFlowTasks.should_log() = true
sch = DataFlowTasks.JuliaScheduler(500)
DataFlowTasks.setscheduler!(sch)


# Work to be traced
# -----------------
work(A) = cholesky_dft!(A)


# Context for the work
# --------------------
nthreads = Threads.nthreads()
tilesizes = 256
DataFlowTasksSandbox.TILESIZE[] = tilesizes
n = 5000
A = rand(n, n)
A = (A + adjoint(A))/2
A = A + n*I


# Set trace category labels
# -------------------------
set_tracelabels("chol", "ldiv", "schur")


# LOGGING
# -------
g = logging(work, Dag, A)

# Decomment to save DAG svg file
# ------------------------------
io = open("./fig/logger/dag__$(n)_$(tilesizes).svg", "w")
GraphViz.render(io, g)
close(io)

# Decomment to save TRACE png file
# ------------------------------
# using Plots
# machine = gethostname()
# savefig("./fig/logger/cholesky_$(machine)_$(n)_$(tilesizes)_$nthreads.png")