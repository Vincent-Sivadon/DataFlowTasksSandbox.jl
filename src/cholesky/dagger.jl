#
# Tiled Cholesky factorization using Dagger.jl
#

# Wrapper
cholesky_dagger!(A::Matrix, s=TILESIZE[]) = _cholesky_dagger!(PseudoTiledMatrix(A,s))

# Implementation
function _cholesky_dagger!(A::PseudoTiledMatrix)
    # Number of blocks
    m,n = size(A)

    # Thunks init
    thunks = Matrix{Dagger.EagerThunk}(undef, m, n)
    for i ∈ 1:m, j ∈ 1:n
        thunks[i, j] = Dagger.@spawn A[i, j] * 1.0
    end

    for i in 1:m
        # Diagonal block
        thunks[i, i] = Dagger.@spawn chol_task(thunks[i, i])      
        
        
        L = adjoint(UpperTriangular(fetch(thunks[i, i])))

        # Forward substitutions
        for j in i+1:n
            thunks[i, j] = Dagger.@spawn TriangularSolve.ldiv!(L,thunks[i, j])
        end

        # Partial submatrix update
        for j in i+1:m
            Aji = adjoint(fetch(thunks[i, j]))
            for k in j:n
                thunks[j, k] = Dagger.@spawn Octavian.matmul_serial!(thunks[j, k], Aji, thunks[i, k],-1,1)
            end
        end
    end

    for i ∈ 1:m, j ∈ i:n
        A[i, j] .= fetch(thunks[i, j])
    end

    return Cholesky(A.data,'U',zero(BlasInt))
end

# Utility spawn thunk
function chol_task(Aii)
    _chol!(Aii)
    Aii
end