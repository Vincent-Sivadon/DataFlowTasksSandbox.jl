using DataFlowTasksSandbox
using Test
using LinearAlgebra

@testset "Unit Choleski Tests" begin
    # Create an SPD matrix
    m = 768
    A = rand(m,m)
    A = (A + adjoint(A))/2
    A = A + m*I

    F_dft = cholesky_dft!(copy(A))
    F_dagger  = cholesky_dagger!(copy(A))

    display(A)
    display(F_dft)
    display(F_dagger)
end

@testset "Choleski" begin
    # create an SPD matrix
    m = 1280
    A = rand(m,m)
    A = (A + adjoint(A))/2
    A = A + m*I

    F = cholesky_dft!(copy(A))
    er = norm(F.L*F.U-A,Inf)/max(norm(A),norm(F.L*F.U))
    @test er < 10^(-10)
    @info "DataFlowTasks error" er

    # Compute Dagger version
    F = cholesky_dagger!(copy(A))
    er = norm(F.L*F.U-A,Inf)/max(norm(A),norm(F.L*F.U))
    @test er < 10^(-10)
    @info "Dagger error" er
end
