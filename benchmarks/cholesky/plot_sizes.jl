using DataFlowTasksSandbox

names = ["openblas", "dft", "dagger", "forkjoin"]
n_cores = 4
sizes = 500:500:5000 |> collect
machine = "LEGION"

plot_sizes(sizes, names, machine, n_cores)

using Plots
savefig("./fig/cholesky/LEGION/sizes.png")