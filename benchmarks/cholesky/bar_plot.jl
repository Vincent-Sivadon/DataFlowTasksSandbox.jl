# Will depend on the data files in the data/cholesky folder
# For a fixed number of threads and a fixed size
# Plots all different version of cholesky factorization

using Plots
using DataFlowTasksSandbox: ROOT_DIR

NB_PROCS = 16
SIZE = 5000

flops(n) = @. 1/3*n^3 + 1/2*n^2

# MAURY 
data_16_1000 = flops(1000)./[
    4.74194e6, 1.2325498e7, 1.321302895e8, 9.6179051e7, 1.2171971e7
]
data_16_5000 = flops(5000)./[
    1.6024726e8, 7.691159115e8, 8.000250201e9, 1.964644585e9, 1.419025059e9
]
data_32_5000 = flops(5000)./[
    1.55114787e8, 1.24873319e8, 7.172437095e9, 2.13590389e9, 1.421884921e9
]


versions = ["openblas", "dft", "dagger", "forkjoin", "tiled_seq"]

files = [ joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_$NB_PROCS.dat")
            for name ∈ versions]
datas = [readdlm(file, '\t', Float64, '\n')
            for file ∈ files]

p = bar(
    title = "GFlops for nb_cores = $NB_PROCS and matrix size = $SIZE\n(maury)",
    ylabel = "GFlops",
    legend=:none,
    color=:purple
)

for i ∈ 1:length(files)
    p = bar!(
        [versions[i]],
        [flops(SIZE)/datas[i][:, 2][end]]
        #[data_32_5000[i]]
    )
end
display(p)

savefig("./fig/cholesky/bar_nc_$(NB_PROCS)_size_$(SIZE).png")