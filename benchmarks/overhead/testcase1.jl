using DataFlowTasks: R,W,RW
using DataFlowTasks
using BenchmarkTools
using Dagger
using LinearAlgebra
using Match

# ***************************************************************
# ***************************************************************

# The task to be spawn a great number of times
function computing(C, A, B, i, j)
    C[i, j] += A[i, j] * B[i, j]
end

function base(A, B, C)
    n, m = size(A)
    for i ∈ 1:n, j ∈ 1:n
        computing(C, A, B, i, j)
    end
end
function dft(A, B, C)
    n, m = size(A)
    for i ∈ 1:n, j ∈ 1:n
        @dspawn computing(C, A, B, i, j) (C, A, B, i, j) (W, R, R, R, R)
    end
end
function dagger(A, B, C)
    n, m = size(A)
    for i ∈ 1:n, j ∈ 1:n
        Dagger.@spawn computing(C, A, B, i, j)
    end
end
function julia(A, B, C)
    n, m = size(A)
    for i ∈ 1:n, j ∈ 1:n
        Threads.@spawn computing(C, A, B, i, j)
    end
end


# ***************************************************************
# ***************************************************************

# Benchmark "func", a task paradigm version of "computing"
function benchmark(func)
    # We'll create n² tasks
    n = 20
    A, B, C = [rand(n, n) for i=1:3]

    # Benchmarks
    @benchmark $func($A, $B, $C)
end

# Compute overhead of task creation for Dagger, DataFlowTasks, Julia Tasks
function overheads()
    @assert Threads.nthreads() == 1

    # Get all benchmarks
    b_without_tasks = benchmark(base)
    b_dagger = benchmark(dagger)
    b_dft    = benchmark(dft)
    b_julia  = benchmark(julia)

    # Compute all overheads
    overhead_dagger = median(b_dagger).time - median(b_without_tasks).time
    overhead_dft    = median(b_dft).time    - median(b_without_tasks).time
    overhead_julia  = median(b_julia).time  - median(b_without_tasks).time
    overhead_dagger *= 10^(-6)
    overhead_dft    *= 10^(-6)
    overhead_julia  *= 10^(-6)

    display("************* Overheads *************")
    display(b_without_tasks)
    display(b_dagger)
    display(b_dft)
    display(b_julia)
    @info overhead_dagger
    @info overhead_dft
    @info overhead_julia
    display("*************************************")
end
overheads()


# ***************************************************************
# ***************************************************************

# In case i want to plot only one overhead
function overhead(func)
    # Get benchmarks
    b_without_tasks = benchmark(base)
    b = benchmark(func)

    # Compute all overheads
    overhead = median(b).time - median(b_without_tasks).time
    overhead *= 10^(-6)

    display(b_without_tasks)
    display(b)
    @info "Overhead" overhead
end
# overhead(dagger)
# overhead(julia)
# overhead(dft)

