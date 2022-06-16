using DataFlowTasks
using DataFlowTasks: R, W, RW
using DataFlowTasksSandbox
using Plots
using LinearAlgebra
using LinearAlgebra: BlasInt
using LoopVectorization
using TriangularSolve
using RecursiveFactorization
using Octavian
using Dagger


# Environnement
# -------------
DataFlowTasks.should_log() = true
sch = DataFlowTasks.JuliaScheduler(500)
DataFlowTasks.setscheduler!(sch)


# Work
# ----
work(A) = cholesky!(A)
function cholesky!(A::Matrix,s=DataFlowTasksSandbox.TILESIZE[],tturbo::Val{T}=Val(false)) where {T}
    _cholesky!(PseudoTiledMatrix(A,s),tturbo)
end
function _cholesky!(A::PseudoTiledMatrix,tturbo::Val{T}=Val(false)) where {T}
    m,n = size(A) # number of blocks
    for i in 1:m
        # _chol!(A[i,i],UpperTriangular)
        @dspawn _chol!(A[i,i],UpperTriangular,tturbo) (A[i,i],) (RW,)
        Aii = A[i,i]
        U = UpperTriangular(Aii)
        L = adjoint(U)
        for j in i+1:n
            Aij = A[i,j]
            # TriangularSolve.ldiv!(L,Aij,tturbo)
            @dspawn TriangularSolve.ldiv!(L,Aij,tturbo) (Aii,Aij) (R,RW)
        end
        for j in i+1:m
            Aij = A[i,j]
            for k in j:n
                # TODO: for k = j, only the upper part needs to be updated,
                # dividing the cost of that operation by two
                Ajk = A[j,k]
                Aji = adjoint(Aij)
                Aik = A[i,k]
                # schur_complement!(Ajk,Aji,Aik,tturbo)
                @dspawn schur_complement!(Ajk,Aji,Aik,tturbo) (Ajk,Aij,Aik) (RW,R,R)
            end
        end
    end
    # wait for all computations before returning
    DataFlowTasks.sync()
    return Cholesky(A.data,'U',zero(BlasInt))
end
function _chol!(A::AbstractMatrix{<:Real}, ::Type{UpperTriangular},tturbo::Val{T}=Val(false)) where {T}
    Base.require_one_based_indexing(A)
    n = LinearAlgebra.checksquare(A)
    @inbounds begin
        for k = 1:n
            Akk = A[k,k]
            for i = 1:k - 1
                Akk -= A[i,k]*A[i,k]
            end
            A[k,k] = Akk
            Akk, info = _chol!(Akk, UpperTriangular)
            if info != 0
                return UpperTriangular(A), info
            end
            A[k,k] = Akk
            AkkInv = inv(Akk')
            if T
                @tturbo warn_check_args=false for j = k + 1:n
                    for i = 1:k - 1
                        A[k,j] -= A[i,k]*A[i,j]
                    end
                end
                @tturbo warn_check_args=false for j in k+1:n
                    A[k,j] = AkkInv*A[k,j]
                end
            else
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
    end
    return UpperTriangular(A), convert(Int32, 0)
end
function _chol!(x::Number, uplo)
    rx = real(x)
    rxr = sqrt(abs(rx))
    rval =  convert(promote_type(typeof(x), typeof(rxr)), rxr)
    rx == abs(x) ? (rval, convert(Int32, 0)) : (rval, convert(Int32, 1))
end


# Context
# -------
DataFlowTasksSandbox.TILESIZE[] = 256
n = 1000
A = rand(n, n)
A = (A + adjoint(A))/2
A = A + n*I

work(A)

# Logging
# -------
# logging(work, TraceLog, A)