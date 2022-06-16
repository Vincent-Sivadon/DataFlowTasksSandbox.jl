# API to make cholesky benchmarks easier

using Match
using BenchmarkTools
using DataFrames
using CSV

n_threads = Threads.nthreads()

function _benchmark(name::String, size::Int, A)
    # Get function according to name
    func = @match name begin
        "openblas"  => cholesky!
        "dft"       => cholesky_dft!
        "dagger"    => cholesky_dagger!
        "forkjoin"  => cholesky_forkjoin!
        "tiled_seq" => cholesky_tiled_seq!
    end

    BLAS.set_num_threads(Threads.nthreads())

    # Benchmark
    b = @benchmark $func(B) setup=(B=copy($A)) evals=1
    t = median(b).time

    # Print
    @info "============= $name ============="
    @info "size = $size"
    @info "t    = $t"
    
    t
end

function benchmark(names::Vector{String}, sizes::Vector{Int})
    machine_name = gethostname()
    n_threads = Threads.nthreads()

    @info "n_cores = $n_threads"
    
    benchmarks = [
        [_benchmark(name , size, SPD!(rand(size,size)) ) for size ∈ sizes]
        for name ∈ names
    ]

    col_names = split(string(sizes), ",", keepempty=false)
    col_names = strip.(col_names, ['['])
    col_names = strip.(col_names, [']'])
    col_names = strip.(col_names, [' '])


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

function SPD!(A)
    A = (A + adjoint(A))/2
    A = A + size(A)[1]*I
end