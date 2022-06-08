# Depending on the number of threads julia started with,
# will write the outputs of the benchmarks of the choleski
# factorization computed with OpenBLAS, DataFlowTasks,
# Dagger, and a forkjoin
# Outputs are in the data folder and will look like :
# Dagger_nc_4.dat (number of cores)

using DataFlowTasksSandbox
using DataFlowTasks
using DataFlowTasks: R, W, RW
using Test
using LinearAlgebra
using BenchmarkTools
using DelimitedFiles

# ***************************** PARAMETERS *****************************

# Number of cores
nt = Threads.nthreads()

capacity = 50
sch = DataFlowTasks.JuliaScheduler(capacity)
DataFlowTasks.setscheduler!(sch)

tilesize = 128
DataFlowTasksSandbox.TILESIZE[] = tilesize

# Matrix sizes
n = 1000


# ***************************** BENCHMARKS *****************************

function benchmarking(func, name)
    # Display
    println("="^30, " ", name, " ", "="^30)
    @info "Number of threads = $nt"

    # BLAS set up
    BLAS.set_num_threads(nt)
    @info "OpenBLAS config"
    @info BLAS.get_config()
    @info "NBLAS = $(BLAS.get_num_threads())"

    
    println("-"^50)

    # ************* Benchmark *************

    # Create an SPD matrix
    A = rand(n,n)
    A = (A + adjoint(A))/2
    A = A + n*I

    b = @benchmark $func(B) setup=(B=copy($A)) evals=1
    t = median(b).time

    # *************** Display ***************

    @info "m                 = $n"
    @info "t                 = $t"
end

benchmarking(cholesky!, "openblas")
benchmarking(cholesky_dft!, "dft")
benchmarking(cholesky_dagger!, "dagger")
benchmarking(cholesky_forkjoin!, "forkjoin")
benchmarking(cholesky_tiled_seq!, "tiled_seq")
