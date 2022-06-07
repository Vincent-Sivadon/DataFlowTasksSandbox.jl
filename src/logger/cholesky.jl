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
    
# Problem 
n = 2000
A = rand(n,n)
A = (A+A') + 2*size(A,1)*I

# First run to compile
F = cholesky_dft!(A)

# Logger init
io = open("$ROOT_DIR/log/cholesky.log", "w+")
logger = Logger(io)

with_logger(logger) do
    F = cholesky_dft!(A)
end

parse!(logger)  

# plot(PlotRunnable(),logger)

# plot(PlotFinished(),logger)

plot(logger, xlims=(logger.tasklogs[1].time_start * 10^(-9), Inf))
title!("Cholesky logger")

# savefig("$ROOT_DIR/fig/logger/cholesky.png")