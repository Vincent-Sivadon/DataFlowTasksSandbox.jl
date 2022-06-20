using DataFlowTasks
using DataFlowTasks: R, W, RW
using LinearAlgebra
using DataFlowTasksSandbox

tilesizes = 1000
DataFlowTasksSandbox.TILESIZE[] = tilesizes
n = 4000
A = rand(n, n)
A = (A + adjoint(A))/2
A = A + n*I

A = PseudoTiledMatrix(A, tilesizes)

DataFlowTasks.should_log() = true

@dspawn _chol!(A[1,1]) (A[1,1],) (RW,)

println("task spawned")

DataFlowTasks.sync()
