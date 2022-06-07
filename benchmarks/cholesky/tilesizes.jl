using DataFlowTasksSandbox
using DataFlowTasks
using DataFlowTasks: R, W, RW
using Dagger
using BenchmarkTools
using LinearAlgebra

# ***************************** PARAMETERS *****************************

# Number of threads
nt = Threads.nthreads()

n = 2560
tilesize = 160
DataFlowTasksSandbox.TILESIZE[] = tilesize


function benchmarking()
    tilesizes = [2560, 1810, 1280, 905, 640, 452, 320, 226]

    # Create an SPD matrix
    A = rand(n,n)
    A = (A + adjoint(A))/2
    A = A + n*I

    # Store
    t_seq    = Vector{Float64}(undef, length(tilesizes))
    t_dft    = Vector{Float64}(undef, length(tilesizes))
    t_dagger = Vector{Float64}(undef, length(tilesizes))

    # Benchmark
    for i ∈ 1:length(tilesizes)
        DataFlowTasksSandbox.TILESIZE[] = tilesizes[i]
        b_seq    = @benchmark cholesky_tiled_seq!(B) setup=(B = copy($A)) evals=1
        b_dft    = @benchmark cholesky_dft!(B)       setup=(B = copy($A)) evals=1
        b_dagger = @benchmark cholesky_dagger!(B)    setup=(B = copy($A)) evals=1

        t_seq[i]    = median(b_seq   ).time
        t_dft[i]    = median(b_dft   ).time
        t_dagger[i] = median(b_dagger).time
    end
    
    @info "Sequentiel    (s) : $t_seq"
    @info "DataFlowTasks (s) : $t_dft"
    @info "Dagger        (s) : $t_dagger"

    t_seq, t_dft, t_dagger
end
# benchmarking()


using Plots
function plotting()
    # tilesizes = 2560, 1280, 640, 320, 160
    nb_blocks = [2^i for i ∈ 0:7]
    # (t_seq, t_dft, t_dagger) = benchmarking()
    t_seq = [9.5642225e8,3.15818545e8, 1.23099317e8, 8.772415e7, 8.94001765e7]
    t_dft = [9.49728196e8, 3.29465581e8, 1.263948185e8, 8.96896385e7, 9.67536765e7]
    t_dagger = [9.77968933e8, 3.41965656e8, 1.35502504e8, 2.17676352e8, 2.210834433e9]

    flops = @. 1/3*2560^3 + 1/2*2560^2

    plot(
        title = "Cholesky factorization for different tilesizes\n Matrix size : 2560, Nb of threads : 1",
        legend=:inside,
        size=(700,500),
        xlabel = "Number of blocks", ylabel = "GFlops",
    )

    plot!(
        nb_blocks, flops./t_seq,
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = :green, lw = 3,
        label = "Sequentiel"
    )


    plot!(
        nb_blocks, flops./t_dft,
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = :purple, lw = 3,
        label = "DataFlowTasks"
    )

    plot!(
        nb_blocks, flops./t_dagger,
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = :orange, lw = 3,
        label = "Dagger"
    )
end
plotting()

savefig("./fig/cholesky/tilesizes.png")