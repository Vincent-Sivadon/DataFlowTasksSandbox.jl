#
# Implementation of the tiled LU factorization algorithm using forkjoin strategy
#

# Wrapper
lu_forkjoin!(A::Matrix, s=TILESIZE[]) = _lu_forkjoin!!(PseudoTiledMatrix(A,s))


# Implementation
function _lu_forkjoin!(A::PseudoTiledMatrix)
    # Number of blocks
    m,n = size(A)

    for i in 1:m
        Aii = A[i,i]
        # FIXME: for simplicity, no pivot is allowed. Pivoting the diagonal
        # blocks requires permuting the corresponding row/columns before continuining
        RecursiveFactorization.lu!(Aii,NoPivot())
        Threads.@threads for j in i+1:n
            Aij = A[i,j]
            Aji = A[j,i]
            TriangularSolve.ldiv!(UnitLowerTriangular(Aii),Aij)
            TriangularSolve.rdiv!(Aji,UpperTriangular(Aii))
        end
        @sync for j in i+1:m
            for k in i+1:n
                Ajk = A[j,k]
                Aji = A[j,i]
                Aik = A[i,k]
                Threads.@spawn Octavian.matmul_serial!(Ajk,Aji,Aik,-1,1)
            end
        end
    end

    # wait for all computations before returning
    DataFlowTasks.sync()
    return LU(A.data,BlasInt[],zero(BlasInt))
end
