# Depends on the data files in the data folder !
# Will plot the evolution of GFlops/s for different versions
# of cholesky factorization

using DelimitedFiles
using Plots
using Match
using DataFlowTasksSandbox: ROOT_DIR

nn = [2^i for i ∈ 0:5]

function plotting_scalability_rel(name, color)
    files = [ joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_$i.dat")
                for i ∈ nn ]
    t = [ readdlm(files[i],  '\t', Float64, '\n')[end, 2]
                for i ∈ 1:length(nn) ]
    
    # Flotting Points Operations
    size = readdlm(files[1],  '\t', Float64, '\n')[end, 1]

    flops = @. 1/3*size^3 + 1/2*size^2

    # Hack to have uppercases on labels
    plot_label = @match name begin
        "openblas"  => "OpenBLAS"
        "dft"       => "DataFlowTasks"
        "dagger"    => "Dagger"
        "forkjoin"  => "Forkjoin"
        "tiled_seq" => "Tiled Sequentiel"
    end
    
    plot!(
        nn, flops./t,
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = color, lw = 3,
        label = plot_label
    )
end

p = plot(
    legend = :topleft,
    xlabel = "Nb of cores", ylabel = "GFlops",
    xticks = 1:2:32, yticks = 0:25:1000,
    title = "Cholesky factorization\nmat_size=5000, maury",
)
plotting_scalability_rel("openblas", :red)
plotting_scalability_rel("dft", :purple)
plotting_scalability_rel("dagger", :orange)
plotting_scalability_rel("forkjoin", :blue)
plotting_scalability_rel("tiled_seq", :green)

savefig("./fig/cholesky/scalability_GFlops_maury.png")