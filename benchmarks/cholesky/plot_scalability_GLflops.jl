# Depends on the data files in the data folder !
# Will plot the evolution of GFlops/s for different versions
# of cholesky factorization

using DelimitedFiles
using Plots
using Match

function plotting_scalability_rel(name, color)
    
    file_1  = joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_1.dat" )
    file_2  = joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_2.dat" )
    file_4  = joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_4.dat" )
    file_8  = joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_8.dat" )
    file_12 = joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_12.dat")
    file_16 = joinpath("$ROOT_DIR/data/cholesky/$name/", "nc_16.dat")

    t_1  = readdlm(file_1,  '\t', Float64, '\n')[end, 2]
    t_2  = readdlm(file_2,  '\t', Float64, '\n')[end, 2]
    t_4  = readdlm(file_4,  '\t', Float64, '\n')[end, 2]
    t_8  = readdlm(file_8,  '\t', Float64, '\n')[end, 2]
    t_12 = readdlm(file_12, '\t', Float64, '\n')[end, 2]
    t_16 = readdlm(file_16, '\t', Float64, '\n')[end, 2]
    
    n_cores   = [1, 2, 4, 8, 12, 16]
    t   = [t_1, t_2, t_4, t_8, t_12, t_16]
    
    # Flotting Points Operations
    size = readdlm(file_1,  '\t', Float64, '\n')[end, 1]
    flops = @. 1/3*size^3 + 1/2*size^2

    # Hack to have uppercases on labels
    plot_label = @match name begin
        "openblas" => "OpenBLAS"
        "dft"      => "DataFlowTasks"
        "dagger"   => "Dagger"
        "forkjoin" => "Forkjoin"
    end
    
    plot!(
        n_cores, flops./t,
        m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
        lc = color, lw = 3,
        label = plot_label
    )
end

p = plot(
    legend = :topleft,
    xlabel = "Nb of cores", ylabel = "GFlops",
    xticks = 1:1:16, yticks = 0:25:1000,
    title = "Cholesky factorization",
)
plotting_scalability_rel("openblas", :red)
plotting_scalability_rel("dft", :purple)
plotting_scalability_rel("dagger", :orange)
plotting_scalability_rel("forkjoin", :blue)

savefig("./fig/cholesky/scalability_GFlops.png")