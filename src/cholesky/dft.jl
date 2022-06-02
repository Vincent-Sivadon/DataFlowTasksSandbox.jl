#
# Tiled Cholesky factorization using DataFlowTasks.jl
#

# Wrapper
cholesky_dft!(A::Matrix, s=TILESIZE[]) = _cholesky_dft!(PseudoTiledMatrix(A, s))

# Implementation
function _cholesky_dft!(A::PseudoTiledMatrix)
    # Number of blocks
    m,n = size(A)

    for i in 1:m
        Aii = A[i,i]
        # _chol!(Aii)
        @dspawn _chol!(Aii) (Aii,) (RW,)
        U = UpperTriangular(Aii)
        L = adjoint(U)
        for j in i+1:n
            Aij = A[i,j]
            # TriangularSolve.ldiv!(L,Aij)
            @dspawn TriangularSolve.ldiv!(L,Aij) (Aii,Aij) (R,RW)
        end
        for j in i+1:m
            Aij = A[i,j]
            for k in j:n
                # TODO: for k = j, only the upper part needs to be updated,
                # dividing the cost of that operation by two
                Ajk = A[j,k]
                Aji = adjoint(Aij)
                Aik = A[i,k]
                # schur_complement!(Ajk,Aji,Aik)
                @dspawn Octavian.matmul_serial!(Ajk,Aji,Aik,-1,1) (Ajk,Aij,Aik) (RW,R,R)
            end
        end
    end
    # wait for all computations before returning
    DataFlowTasks.sync()
    return Cholesky(A.data,'U',zero(BlasInt))
end