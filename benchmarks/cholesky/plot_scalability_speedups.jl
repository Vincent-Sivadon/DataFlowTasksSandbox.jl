using DelimitedFiles
using Plots
using Match

const ROOT_DIR = pkgdir(DataFlowTasksSandbox)

function plotting_scalability(name, color)
    n = [2^i for i ∈ 0:4]

    # Get reference data (tiled seq)
    # -----------------------------
    files_ref = [joinpath("$ROOT_DIR/data/cholesky/tiled_seq/", "nc_$i.dat")
                    for i ∈ n ]
    t_ref = [ readdlm(files_ref[i],  '\t', Float64, '\n')[end, 2]
                for i ∈ 1:5 ]

    # Get current version of interest's data
    # --------------------------------------
    files = [ joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_$i.dat")
                for i ∈ n ]
    t = [ readdlm(files[i],  '\t', Float64, '\n')[end, 2]
            for i ∈ 1:5 ]
    
    # Compute speedups
    speedups = ones(5)
    @. speedups[:] = t_ref[:] / t[:]

    # Hack to have uppercases on labels
    plot_label = @match name begin
        "openblas"  => "OpenBLAS"
        "dft"       => "DataFlowTasks"
        "dagger"    => "Dagger"
        "forkjoin"  => "Forkjoin"
        "tiled_seq" => "Tiled Sequentiel"
    end
    
    plot!(
        n, speedups,
        #yerrors = (flops./min, flops./max),
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = color, lw = 3,
        label = plot_label
    )
end

p = plot(
    [1, 16], [1, 16],
    legend = :topleft,
    xticks = 1:1:16, yticks = 1:1:16,
    label = "Linear scalability (ideal)",
    xlabel = "Nb of cores", ylabel = "Speedups",
    title = "Cholesky factorization scalability",
    lc = :green, lw = 3
)
plotting_scalability("openblas", :red)
plotting_scalability("dft", :purple)
plotting_scalability("dagger", :orange)
plotting_scalability("forkjoin", :blue)

savefig("./fig/cholesky/scalability_speedups.png")