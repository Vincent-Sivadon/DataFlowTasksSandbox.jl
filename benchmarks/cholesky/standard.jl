using LinearAlgebra
using DataFlowTasksSandbox
using BenchmarkTools

function main(m)

    # Create an SPD matrix
    A = rand(m,m)
    A = (A + adjoint(A))/2
    A = A + m*I

    b_std_mod = @benchmark _chol!(B) setup=(B=copy($A)) evals=1
    b_std = @benchmark LinearAlgebra.cholesky!(B) setup=(B=copy($A)) evals=1

    display(b_std_mod)
    display(b_std)

end
main(500)