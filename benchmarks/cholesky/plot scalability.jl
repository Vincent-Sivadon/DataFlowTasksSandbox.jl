using DataFlowTasksSandbox
using Plots

ENV["GKSwstype"]="nul"

names = ["openblas", "dft", "dagger", "forkjoin"]
n_cores = [1, 2, 4, 8]
mat_size = 5000
machine = "muscat"

plot_scalability(n_cores, names, machine, mat_size)
