#
# Implementation of the tiled cholesky factorization using a forjoin strategy
#

# Wrapper
cholesky_forkjoin!(A::Matrix,s=TILESIZE[]) = _cholesky_forkjoin!(PseudoTiledMatrix(A,s))

# Implementation
function _cholesky_forkjoin!(A::PseudoTiledMatrix)
    # Number of blocks
    m,n = size(A)
    
    for i in 1:m
        LinearAlgebra.cholesky!(A[i,i])
        Aii = A[i,i]
        U = UpperTriangular(Aii)
        L = adjoint(U)
        Threads.@threads for j in i+1:n
            Aij = A[i,j]
            TriangularSolve.ldiv!(L,Aij,tturbo)
        end
        # spawn m*(m+1)/2 tasks and sync them at the end
        @sync for j in i+1:m
            Aij = A[i,j]
            for k in j:n
                Ajk = A[j,k]
                Aji = adjoint(Aij)
                Aik = A[i,k]
                Threads.@spawn schur_complement!(Ajk,Aji,Aik,tturbo)
            end
        end
    end
    return Cholesky(A.data,'U',zero(Int32))
end
