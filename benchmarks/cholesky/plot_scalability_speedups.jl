using DelimitedFiles
using Plots
using Match
using DataFlowTasksSandbox: ROOT_DIR

# Get reference data (tiled seq)
# -----------------------------
nn = [2^i for i ∈ 0:5]
file_ref = joinpath("$ROOT_DIR/data/cholesky/tiled_seq/", "nc_1.dat")
t_ref = readdlm(file_ref,  '\t', Float64, '\n')[end, 2]

function plotting_scalability(name, color)
    # Get current version of interest's data
    # --------------------------------------
    files = [ joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_$i.dat")
                for i ∈ nn ]
    t = [ readdlm(files[i],  '\t', Float64, '\n')[end, 2]
            for i ∈ 1:length(nn) ]
    
    # Compute speedups
    speedups = ones(length(nn))
    speedups[:] = t_ref ./ t[:]

    # Hack to have uppercases on labels
    plot_label = @match name begin
        "openblas"  => "OpenBLAS"
        "dft"       => "DataFlowTasks"
        "dagger"    => "Dagger"
        "forkjoin"  => "Forkjoin"
    end
    
    plot!(
        nn, speedups,
        #yerrors = (flops./min, flops./max),
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = color, lw = 3,
        label = plot_label
    )
end


p = plot(
    [1:32], [1:32],
    legend = :topleft,
    xticks = 1:2:34,
    label = "Tiled Sequentiel",
    xlabel = "Nb of cores", ylabel = "Speedups",
    title = "Cholesky factorization scalability\n matrix size = 5000",
    lc = :green, lw = 3
)
plotting_scalability("openblas", :red)
plotting_scalability("dft", :purple)
plotting_scalability("dagger", :orange)
plotting_scalability("forkjoin", :blue)

savefig("./fig/cholesky/scalability_speedups.png")