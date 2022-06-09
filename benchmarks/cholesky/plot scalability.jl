using DataFlowTasksSandbox

names = ["openblas", "dft"]
n_cores = [1, 2, 4]
mat_size = 5000
machine = "LEGION"

plot_scalability(n_cores, names, machine, mat_size)
