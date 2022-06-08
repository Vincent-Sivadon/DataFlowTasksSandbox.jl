# Will depend on the data files in the data/cholesky folder
# For a fixed number of threads and a fixed size
# Plots all different version of cholesky factorization

using Plots
using DataFlowTasksSandbox: ROOT_DIR

NB_PROCS = 8
SIZE = 5000

versions = ["dft", "dagger", "openblas", "tiled_seq", "forkjoin"]
files = [ joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_$NB_PROCS.dat")
            for name ∈ versions]
datas = [readdlm(file, '\t', Float64, '\n')
            for file ∈ files]

p = bar(
    title = "GFlops for nb_cores = $NB_PROCS and matrix size = $SIZE\nserveur maury",
    ylabel = "GFlops",
    legend=:none,
    color=:purple
)

for i ∈ 1:length(files)
    p = bar!(
        [versions[i]], [datas[i][:, 2][end]]
    )
end
display(p)

savefig("./fig/cholesky/bar_nc_$(NB_PROCS)_size_$(SIZE).png")