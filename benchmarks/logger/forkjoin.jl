using DataFlowTasks
using DataFlowTasks: R, W, RW
using DataFlowTasksSandbox
using LinearAlgebra
using GraphViz: Graph

# Environnement
# -------------
DataFlowTasks.should_log() = true
sch = DataFlowTasks.JuliaScheduler(500)
DataFlowTasks.setscheduler!(sch)


# Work
# ----

# define a simple function to mimic a problem with fork-join parallelization.
# The execution starts with one node, spawns `n` independent nodes, and then
# joint them later at a last node. The  computation waits for the last node, and
# each block works for `s` seconds
function fork_join(n,s)
    A = rand(2n)
    @dspawn do_work(s) (A,) (RW,)
    for i in 1:n
        @dspawn do_work(s) (view(A,[i,i+n]),) (RW,)
    end
    res = @dspawn do_work(s) (A,) (R,)
    return res
end
function do_work(t)
    ti = time()
    while (time()-ti) < t end
    return
end

# Context
# -------
m = 20
s = 0.1

# Logging
# -------
set_tracelabels() # in case we've already given values to tracelabels
logging(fork_join, Trace, m, s)