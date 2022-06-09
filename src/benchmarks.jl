# API to make cholesky benchmarks easier

using Match
using BenchmarkTools
using DataFrames
using CSV

function _bench(name::String, size::Int)
    # Get function according to name
    func = @match name begin
        "openblas"  => cholesky!
        "dft"       => cholesky_dft!
        "dagger"    => cholesky_dagger!
        "forkjoin"  => cholesky_forkjoin!
        "tiled_seq" => cholesky_tiled_seq!
    end

    BLAS.set_num_threads(Threads.nthreads())

    # Create an SPD matrix
    m = size
    A = rand(m,m)
    A = (A + adjoint(A))/2
    A = A + m*I

    # Benchmark
    b = @benchmark $func(B) setup=(B=copy($A)) evals=1

    median(b).time
end

function bench(names::Vector{String}, sizes::Vector{Int})
    benchmarks = [ [_bench(name , size) for size ∈ sizes] for name ∈ names ]

    col_names = split(string(sizes), ",", keepempty=false)
    col_names = strip.(col_names, ['['])
    col_names = strip.(col_names, [']'])
    col_names = strip.(col_names, [' '])

    machine_name = gethostname()
    n_threads = Threads.nthreads()

    for i ∈ 1:length(benchmarks)
        # Open data file
        name = names[i]
        filepath = joinpath(machine_name, name*".csv")
        filepath = joinpath("data", filepath)
        filepath = joinpath(ROOT_DIR, filepath)
        df = DataFrame(CSV.File(filepath))

        # Write in DataFrame
        for j ∈ 1:length(col_names)
            index = Int(log2(n_threads)) + 1
            df[index,col_names[j]] = benchmarks[i][j]
        end

        # Update file according to modified DataFrame
        CSV.write(filepath, df)
    end
end

function init_csv_files(machine::String)
    # Data matrix
    data = zeros(6, 10)

    # Get col names (sizes)
    sizes = 500:500:5000 |> collect
    names = split(string(sizes), ',', keepempty=false)
    names = strip.(names, ['['])
    names = strip.(names, [']'])
    names = strip.(names, [' '])

    df = DataFrame(data, names)

    for name ∈ ["openblas", "dft", "dagger", "forkjoin", "tiled_seq"]
        filepath = joinpath(machine, name*".csv")
        filepath = joinpath("data", filepath)
        filepath = joinpath(ROOT_DIR, filepath)
        CSV.write(filepath, df)
    end
end