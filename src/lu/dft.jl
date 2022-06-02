#
# Implementation of the tiled LU factorization algorithm using DataFlowTasks.jl
#

# Wrapper
lu_dft!(A::Matrix, s=TILESIZE[]) = _lu_dft!(PseudoTiledMatrix(A,s))

# Implementation
function _lu_dft!(A::PseudoTiledMatrix)
    # Number of blocks
    m,n = size(A)

    for i in 1:m
        Aii = A[i,i]
        # TODO: for simplicity, no pivot is allowed. Pivoting the diagonal
        # blocks requires permuting the corresponding row/columns before continuining
        @dspawn RecursiveFactorization.lu!(Aii,NoPivot()) (Aii,) (RW,)
        # @dspawn LinearAlgebra.lu!(Aii) (Aii,) (RW,)
        for j in i+1:n
            Aij = A[i,j]
            Aji = A[j,i]
            @dspawn begin
                TriangularSolve.ldiv!(UnitLowerTriangular(Aii),Aij)
                TriangularSolve.rdiv!(Aji,UpperTriangular(Aii))
            end (Aii,Aij,Aji) (R,RW,RW)
            # TriangularSolve.ldiv!(UnitLowerTriangular(Aii),Aij,tturbo)
            # TriangularSolve.rdiv!(Aji,UpperTriangular(Aii),tturbo)
        end
        for j in i+1:m
            for k in i+1:n
                Ajk = A[j,k]
                Aji = A[j,i]
                Aik = A[i,k]
                @dspawn Octavian.matmul_serial!(Ajk,Aji,Aik,-1,1) (Ajk,Aji,Aik) (RW,R,R)
            end
        end
    end
    # wait for all computations before returning
    DataFlowTasks.sync()
    return LU(A.data,BlasInt[],zero(BlasInt))
end
