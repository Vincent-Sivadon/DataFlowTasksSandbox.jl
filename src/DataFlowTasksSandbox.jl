module DataFlowTasksSandbox

const ROOT_DIR = pkgdir(DataFlowTasksSandbox)

using DataFlowTasks
using DataFlowTasks: R, W, RW
using Dagger

using LinearAlgebra
using LinearAlgebra: BlasInt
using LoopVectorization
using TriangularSolve
using RecursiveFactorization
using Octavian

using BenchmarkTools

# Pseudo Tiled Matrix structure
include("pseudo_tiled_matrix.jl")

# Cholesky factorization
# **********************
include("cholesky/standard.jl")
include("cholesky/dft.jl")
include("cholesky/dagger.jl")
include("cholesky/forkjoin.jl")

# LU factorization
# ****************
include("lu/dft.jl")
include("lu/forkjoin.jl")

# Benchmarks
# ****************
include("benchmarks.jl")
include("graphs.jl")

export
    PseudoTiledMatrix,
    _chol!, cholesky_tiled_seq!,
    cholesky_dft!, cholesky_dagger!, cholesky_forkjoin!,
    ROOT_DIR,
    bench, init_csv_files, plot_scalability, plot_sizes

end # module
