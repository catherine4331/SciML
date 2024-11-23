A = 1:9

sz = (3, 3)

i = 3
j = 2

A[i + (j-1)*3]

A = rand(100,100)
B = rand(100,100)
C = rand(100,100)
using BenchmarkTools
function inner_rows!(C,A,B)
  for i in 1:100, j in 1:100
    C[i,j] = A[i,j] + B[i,j]
  end
end
@btime inner_rows!(C,A,B)

function inner_cols!(C,A,B)
    for j in 1:100, i in 1:100
      C[i,j] = A[i,j] + B[i,j]
    end
  end
@btime inner_cols!(C,A,B)

function inner_alloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = [A[i,j] + B[i,j]]
      C[i,j] = val[1]
    end
  end
@btime inner_alloc!(C,A,B)

function inner_alloc(A,B)
    C = similar(A)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end

    C
  end
@btime inner_alloc(A,B)

function inner_noalloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end
  end
@btime inner_noalloc!(C,A,B)

using StaticArrays
val = SVector{3, Float64}(1.0, 2.0, 3.0)
typeof(val)

function static_inner_alloc!(C,A,B)
  for j in 1:100, i in 1:100
    val = @SVector [A[i,j] + B[i,j]]
    C[i,j] = val[1]
  end
end
@btime static_inner_alloc!(C,A,B)

@macroexpand @SVector [A[i,j] + B[i,j]]

function f(A, B)
    # 10 * (A + B)
    C = similar(A)
    for k in 1:10
        # A + B
        C .+= A .+ B
    end

    C
end
@btime f(A, B)

fused(A, B, C) = A .+ B .+ C
@btime fused(A, B, C)

D = similar(A)
fused_output!(D, A, B, C) = D .=  A .+ B .+ C
@btime fused_output!(D, A, B, C)

function non_vectorized!(tmp, A, B, C)
    @inbounds for i in eachindex(tmp)
        tmp[i] = A[i] * B[i] * C[i]
    end
    
    nothing
end
@btime non_vectorized!(D, A, B ,C)