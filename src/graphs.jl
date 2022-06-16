flops(n) = 1/3*n^3 + 1/2*n^2

function plot_scalability(n_cores, names, machine, mat_size)
    # Initial plot
    p = plot(
        title="Cholesky scalability\nmat size=$mat_size on $machine",
        legend=:topleft,
        xlabel="Nb of cores", ylabel="GFlops"
    )

    for name ∈ names
        # Get filepath
        filepath = joinpath(machine, name*".csv")
        filepath = joinpath("data", filepath)
        filepath = joinpath(ROOT_DIR, filepath)

        # Get data
        df = DataFrame(CSV.File(filepath))

        selected_rows = Int.(log2.(n_cores) .+ 1)
        selected_rows_view = selected_rows[1]:selected_rows[end]
       
        y = flops(mat_size) ./ Vector(df[selected_rows_view, string(mat_size)])
        x = n_cores

        plot!(
            x, y,
            m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
            lw = 3,
            label=name
        )
    end

    p
end

function plot_sizes(sizes, names, machine, n_cores)
    # Initial plot
    p = plot(
        title="Cholesky factorization\nNb of cores=$n_cores on $machine",
        legend=:topleft,
        xlabel="Matrix Size", ylabel="GFlops"
    )

    for name ∈ names
        # Get filepath
        filepath = joinpath(machine, name*".csv")
        filepath = joinpath("data", filepath)
        filepath = joinpath(ROOT_DIR, filepath)

        # Get data
        df = DataFrame(CSV.File(filepath))

        cols = split(string(sizes), ',', keepempty=false)
        cols = strip.(cols, ['['])
        cols = strip.(cols, [']'])
        cols = strip.(cols, [' '])

        y = zeros(length(cols))
        for i ∈ 1:length(cols)
            row = Int(log2(n_cores)) + 1
            y[i] = flops(sizes[i]) ./ df[row, cols[i]]
        end
        x = sizes
        

        plot!(
            x, y,
            m = :o, mc = :white, markerstrokewidth = 2, markersize = 5,
            lw = 3,
            label=name
        )
    end

    p
end