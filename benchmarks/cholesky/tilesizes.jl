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
    t_seq =  [9.606243185e8, 4.30590706e8, 3.17361436e8, 1.87195971e8, 1.231655175e8, 9.48970255e7, 8.2615358e7, 8.88310475e7]
    t_dft =  [9.55663854e8, 4.30671664e8, 3.21020442e8, 1.914623475e8, 1.25252885e8, 9.6340669e7, 8.4530204e7, 9.3576361e7]
    t_dagger = [1.005935355e9, 4.48136324e8, 3.41689981e8, 1.91398889e8, 1.31283478e8, 1.51273213e8, 1.96978325e8, 4.96712556e8]

    flops = @. 1/3*2560^3 + 1/2*2560^2

    plot(
        title = "Cholesky factorization for different tilesizes\n Matrix size : 2560, Nb of threads : 1",
        legend=:topleft,
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