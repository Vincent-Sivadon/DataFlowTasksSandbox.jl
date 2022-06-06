using DataFlowTasks
using DataFlowTasks: R, W, RW
using DataFlowTasks: memory_overlap
using Dagger
using BenchmarkTools
using Dagger

const NITER = 40

# Tasks
Iᵢ(Vᵢ) = (Vᵢ += 1)
Sᵢ(V, i) = (V[i] += sum(V))


# ***************************************************************
# ***************************************************************

function base(V)
    n = length(V)

    # Steps
    for i ∈ 1:n
        Iᵢ(V[i])
    end        
    for k ∈ 1:NITER
        for i ∈ 1:n
            Sᵢ(V, i)
        end
    end
end

function dagger(V)
    n = length(V)

    thunks = Vector{Dagger.EagerThunk}(undef, n)
    for i ∈ 1:n
        thunks[i] = Dagger.@spawn V[i] * 1
    end

    # Init
    for i ∈ 1:n
        thunks[i] = Dagger.@spawn Iᵢ(thunks[i]) 
    end

    # Steps
    for k ∈ 1:NITER
        for i ∈ 1:n
            thunks[i] = Dagger.@spawn Sᵢ(fetch.(thunks), i)
        end
    end

    for i ∈ 1:n
        fetch(thunks[i])
    end
end

function dft(V)
    n = length(V)

    # Init
    for i ∈ 1:n
        @dspawn Iᵢ(V[i]) (V[i],) (RW,)
    end

    # Steps
    for k ∈ 1:NITER
        for i ∈ 1:n
            @dspawn Sᵢ(V, i) (V[1:i-1], V[i], V[i+1:n], i) (R, RW, R, R)
        end
    end

    DataFlowTasks.sync()
end


# ***************************************************************
# ***************************************************************


function benchmark(func)
    @assert Threads.nthreads() == 1

    # Problem Initialization
    n = 10
    V = rand(n)

    # Benchmarks
    @benchmark $func($V)
end

# Compute all overheads
function overheads()
    b        = benchmark(base)
    b_dagger = benchmark(dagger)
    b_dft    = benchmark(dft)

    display(b)
    display(b_dagger)
    display(b_dft)
end
overheads()