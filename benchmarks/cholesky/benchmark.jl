using DataFlowTasksSandbox

# Sizes
n_min = 500
n_max = 5000
step = 500
nn = n_min:step:n_max |> collect

# Names
names = ["forkjoin"]

# Benchmarks
benchmark(names, nn)