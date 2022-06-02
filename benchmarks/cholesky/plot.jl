# Depends on the data files in the data folder !
# Will plot the evolution of GFlops/s for different versions
# of cholesky factorization

using DelimitedFiles
using Plots
using Match

const ROOT_DIR = pkgdir(DataFlowTasksSandbox)

function plotting(name, color, nthreads)
    
    file = joinpath("$ROOT_DIR/data/$name/", "nc_$nthreads.dat")
    data = readdlm(file, '\t', Float64, '\n')
    
    n   = data[:, 1]
    t   = data[:, 2]
    
    # Flotting Points Operations
    flops = @. 1/3*n^3 + 1/2*n^2

    # Hack to have uppercases on labels
    plot_label = @match name begin
        "openblas" => "OpenBLAS"
        "dft"      => "DataFlowTasks"
        "dagger"   => "Dagger"
        "forkjoin" => "Forkjoin"
    end
    
    plot!(
        n, flops./t,
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = color, lw = 3,
        label = plot_label
    )


end

# Determines wich graph to plot
nthreads = 8
p = plot(
    legend = :topleft,
    xlabel = "n", ylabel = "GFlops",
    xticks = 500:500:5000, yticks = 0:25:1000,
    title = "Cholesky factorization nt=$nthreads",
)
plotting("openblas", :red, nthreads)
plotting("dft", :purple, nthreads)
plotting("dagger", :orange, nthreads)
plotting("forkjoin", :blue, nthreads)

savefig("./fig/cholesky/nc_$nthreads.png")