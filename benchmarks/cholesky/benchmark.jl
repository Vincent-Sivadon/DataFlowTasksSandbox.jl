using DataFlowTasksSandbox

# Sizes
n_min = 500
n_max = 1500
step = 500
nn = n_min:step:n_max |> collect

# Names
names = ["openblas", "dft"]

# Benchmarks
bench(names, nn)