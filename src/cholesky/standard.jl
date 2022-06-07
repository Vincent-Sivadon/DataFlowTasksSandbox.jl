#
# Implementation of a modified version of the cholesky factorization from LinearAlgebra (MIT license)
#

cholesky_tiled_seq!(A::Matrix,s=TILESIZE[]) = _cholesky_tiled_seq!(PseudoTiledMatrix(A,s))
function _cholesky_tiled_seq!(A::PseudoTiledMatrix)
    # Number of blocks
    m,n = size(A)

    for i in 1:m
        Aii = A[i,i]
        # _chol!(Aii)
        _chol!(Aii)
        U = UpperTriangular(Aii)
        L = adjoint(U)
        for j in i+1:n
            Aij = A[i,j]
            # TriangularSolve.ldiv!(L,Aij)
            TriangularSolve.ldiv!(L,Aij)
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
                Octavian.matmul_serial!(Ajk,Aji,Aik,-1,1)
            end
        end
    end
    return Cholesky(A.data,'U',zero(BlasInt))
end

# Computes the Cholesky factorization of A inplace
# A must be SPD for Cholesky, so we only care for the
# upper triangular part of A 
function _chol!(A::AbstractMatrix{<:Real})
    Base.require_one_based_indexing(A)
    n = LinearAlgebra.checksquare(A)
    @inbounds begin
        for k = 1:n
            Akk = A[k,k]
            for i = 1:k - 1
                Akk -= A[i,k]*A[i,k]
            end
            A[k,k] = Akk
            Akk, info = _chol!(Akk)
            if info != 0
                return UpperTriangular(A), info
            end
            A[k,k] = Akk
            AkkInv = inv(Akk')
            @turbo warn_check_args=false for j = k + 1:n
                for i = 1:k - 1
                    A[k,j] -= A[i,k]*A[i,j]
                end
            end
            @turbo warn_check_args=false for j in k+1:n
                A[k,j] = AkkInv*A[k,j]
            end
        end
    end
    return UpperTriangular(A), convert(Int32, 0)
end

# Same but with @tturbo
function _chol!(A::AbstractMatrix{<:Real}, tturbo)
    Base.require_one_based_indexing(A)
    n = LinearAlgebra.checksquare(A)
    @inbounds begin
        for k = 1:n
            Akk = A[k,k]
            for i = 1:k - 1
                Akk -= A[i,k]*A[i,k]
            end
            A[k,k] = Akk
            Akk, info = _chol!(Akk)
            if info != 0
                return UpperTriangular(A), info
            end
            A[k,k] = Akk
            AkkInv = inv(Akk')
            @tturbo warn_check_args=false for j = k + 1:n
                for i = 1:k - 1
                    A[k,j] -= A[i,k]*A[i,j]
                end
            end
            @tturbo warn_check_args=false for j in k+1:n
                A[k,j] = AkkInv*A[k,j]
            end
        end
    end
    return UpperTriangular(A), convert(Int32, 0)
end

## Numbers
function _chol!(x::Number)
    rx = real(x)
    rxr = sqrt(abs(rx))
    rval =  convert(promote_type(typeof(x), typeof(rxr)), rxr)
    rx == abs(x) ? (rval, convert(Int32, 0)) : (rval, convert(Int32, 1))
end

# Utility
function schur_complement!(C,A,B,tturbo::Val{T}) where {T}
    # RecursiveFactorization.schur_complement!(C,A,B,tturbo) // usually slower than Octavian
    if T
        Octavian.matmul!(C,A,B,-1,1)
    else
        Octavian.matmul_serial!(C,A,B,-1,1)
    end
end