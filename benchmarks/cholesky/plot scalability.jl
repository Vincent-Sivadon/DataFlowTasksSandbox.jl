using DataFlowTasksSandbox
using Plots

# ENV["GKSwstype"]="nul"

names = ["openblas", "dft", "dagger", "forkjoin"]
n_cores = [1, 2, 4]
mat_size = 5000
machine = "LEGION"

plot_scalability(n_cores, names, machine, mat_size)
# savefig("fig/cholesky/LEGION_scalability.png")