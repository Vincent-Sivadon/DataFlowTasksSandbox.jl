using Test
using DataFlowTasksSandbox
using DataFlowTasksSandbox: ROOT_DIR
using DataFlowTasks
using DataFlowTasks: R, W, RW
using DataFlowTasks: Logger, parse!, PlotFinished, PlotRunnable
using LinearAlgebra
using Logging
using Plots


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

# Get DFT scheduler
sch = DataFlowTasks.JuliaScheduler(500)
DataFlowTasks.setscheduler!(sch)
    
# Variables
m = 400
s = 0.1

# First run to compile
fetch(fork_join(m, s))

# Logger init
io = open("$ROOT_DIR/log/forkjoin.log", "w+")
logger = Logger(io)

with_logger(logger) do
    F = fetch(fork_join(m, s))
end

parse!(logger)  

# plot(PlotRunnable(),logger)

# plot(PlotFinished(),logger)

plot(logger, xlims=(logger.tasklogs[1].time_start * 10^(-9), Inf))
title!("Forkjoin example logger")

# savefig("$ROOT_DIR/fig/logger/forkjoin.png")