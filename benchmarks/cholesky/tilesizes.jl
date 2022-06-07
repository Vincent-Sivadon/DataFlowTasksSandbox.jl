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
    tilesizes = [2560, 1280, 640, 320, 160]

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
    nb_blocks = [1, 4, 16, 64, 256]
    (t_seq, t_dft, t_dagger) = benchmarking()

    flops = @. 1/3*2560^3 + 1/2*2560^2

    plot(
        title = "GFlops for different tilesizes",
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