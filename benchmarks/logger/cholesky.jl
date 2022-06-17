using DataFlowTasks
using DataFlowTasks: R, W, RW
using LinearAlgebra
using DataFlowTasksSandbox

# Desactivate plotting if it is a server
servers = ["maury", "muscat", "maranges"]
current = gethostname()
is_server = isempty(findall(str -> str == current, a))
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
tilesizes = 1000
DataFlowTasksSandbox.TILESIZE[] = tilesizes
n = 4000
A = rand(n, n)
A = (A + adjoint(A))/2
A = A + n*I

work(A)

logging(work, TraceLog, A)

# savefig("./fig/logger/cholesky_muscat_$(n)_$(tilesizes)_$nthreads.png")