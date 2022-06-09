using DataFlowTasksSandbox

names = ["openblas"]
n_cores = 4
sizes = [500, 5000]
machine = "LEGION"

plot_sizes(sizes, names, machine, n_cores)
