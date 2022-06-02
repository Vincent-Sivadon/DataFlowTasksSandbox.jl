using DelimitedFiles
using Plots
using Match

const ROOT_DIR = pkgdir(DataFlowTasksSandbox)

function plotting_scalability(name, color)
    
    file_1  = joinpath("$ROOT_DIR/data/$name/", "nc_1.dat" )
    file_2  = joinpath("$ROOT_DIR/data/$name/", "nc_2.dat" )
    file_4  = joinpath("$ROOT_DIR/data/$name/", "nc_4.dat" )
    file_8  = joinpath("$ROOT_DIR/data/$name/", "nc_8.dat" )
    file_12 = joinpath("$ROOT_DIR/data/$name/", "nc_12.dat")
    file_16 = joinpath("$ROOT_DIR/data/$name/", "nc_16.dat")
    
    t_1  = readdlm(file_1,  '\t', Float64, '\n')[end, 2]
    t_2  = readdlm(file_2,  '\t', Float64, '\n')[end, 2]
    t_4  = readdlm(file_4,  '\t', Float64, '\n')[end, 2]
    t_8  = readdlm(file_8,  '\t', Float64, '\n')[end, 2]
    t_12 = readdlm(file_12, '\t', Float64, '\n')[end, 2]
    t_16 = readdlm(file_16, '\t', Float64, '\n')[end, 2]
    
    n_cores   = [1, 2, 4, 8, 12, 16]
    speedups  = [1.0, t_1/t_2, t_1/t_4, t_1/t_8, t_1/t_12, t_1/t_16]

    # Hack to have uppercases on labels
    plot_label = @match name begin
        "openblas" => "OpenBLAS"
        "dft"      => "DataFlowTasks"
        "dagger"   => "Dagger"
        "forkjoin" => "Forkjoin"
    end
    
    plot!(
        n_cores, speedups,
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