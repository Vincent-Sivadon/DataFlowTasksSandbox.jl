#
# Tiled Cholesky factorization using DataFlowTasks.jl
#

# Wrapper
cholesky_dft!(A::Matrix, s=TILESIZE[]) = _cholesky_dft!(PseudoTiledMatrix(A, s))

# Implementation
function _cholesky_dft!(A::PseudoTiledMatrix)
    m,n = size(A) # number of blocks
    for i in 1:m
        @dspawn _chol!(A[i,i]) (A[i,i],) (RW,) 0 "chol"
        Aii = A[i,i]
        U = UpperTriangular(Aii)
        L = adjoint(U)
        for j in i+1:n
            Aij = A[i,j]
            @dspawn TriangularSolve.ldiv!(L,Aij, Val(false)) (Aii,Aij) (R,RW) 0 "ldiv"
        end
        for j in i+1:m
            Aij = A[i,j]
            for k in j:n
                Ajk = A[j,k]
                Aji = adjoint(Aij)
                Aik = A[i,k]
                @dspawn Octavian.matmul_serial!(Ajk, Aji, Aik, -1, 1) (Ajk,Aij,Aik) (RW,R,R) 0 "schur"
            end
        end
    end

    # wait for all computations before returning
    DataFlowTasks.sync()
    return Cholesky(A.data,'U',zero(BlasInt))
end