using DataFlowTasksSandbox

names = ["openblas", "dft", "dagger", "forkjoin"]
n_cores = 4
sizes = 500:500:5000 |> collect
machine = "muscat"

plot_sizes(sizes, names, machine, n_cores)
