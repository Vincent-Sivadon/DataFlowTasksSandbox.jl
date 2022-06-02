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

tilesize = 256
DataFlowTasksSandbox.TILESIZE[] = tilesize

# Matrix sizes
max_size = 5000
min_size = 1000
step     = 500
nn    = min_size:step:max_size |> collect
nb_elts = Int(1 + (max_size - min_size)/step)


# ***************************** BENCHMARKS *****************************

function benchmarking(func, name)
    # Data vector allocations
    t   = Vector{Float64}(undef, nb_elts)
    std = Vector{Float64}(undef, nb_elts)
    t_max = Vector{Float64}(undef, nb_elts)
    t_min = Vector{Float64}(undef, nb_elts)

    # Display
    println("="^30, " ", name, " ", "="^30)
    @info "Number of threads = $nt"

    # BLAS set up
    BLAS.set_num_threads(nt)
    @info "OpenBLAS config"
    @info BLAS.get_config()
    @info "NBLAS = $(BLAS.get_num_threads())"

    
    for i in 1:nb_elts
        println("-"^50)

        # ************* Benchmark *************

        # Create an SPD matrix
        m = nn[i]
        A = rand(m,m)
        A = (A + adjoint(A))/2
        A = A + m*I

        b = @benchmark $func(B) setup=(B=copy($A)) evals=1
        t[i]   = median(b).time

        # *************** Error ***************

        DataFlowTasks.TASKCOUNTER[] = 1 # reset task counter to display how many tasks were created for
        F = func(copy(A))
        er = norm(F.L*F.U-A,Inf)/max(norm(A),norm(F.L*F.U))


        # *************** Display ***************

        @info "m                 = $(m)"
        @info "Number of tasks   = $(DataFlowTasks.TASKCOUNTER[])"
        @info "error             = $er"
        @info "t                 = $(t[i])"
    end

    # Write times in file
    filename = joinpath("$ROOT_DIR/data/$name/", "nc_$nt.dat")
    open(filename, "w") do io
        writedlm(io, [nn t t_min t_max], "\t")
    end

    nothing
end

benchmarking(cholesky!, "openblas")
benchmarking(cholesky_dft!, "dft")
benchmarking(cholesky_dagger!, "dagger")
benchmarking(cholesky_forkjoin!, "forkjoin")
