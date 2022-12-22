
using LinearAlgebra

Base.@kwdef mutable struct dtw_point
    c::Float64 = Inf
    pre::Pair{Int64, Int64} = Pair(0, 0)
end

function dtw(s, t) 
    n::Int64, m::Int64 = size(s)[1], size(t)[1]
    dtw_matrix::Matrix{dtw_point} = map(deepcopy, fill(dtw_point(), n+1, m+1))
    dtw_matrix[1, 1].c = 0

    for i::Int64=2:n+1
        for j::Int64=2:m+1
            cost::Float64 = norm(s[i-1] - t[j-1])
            tmp::Vector{Float64} = [
                dtw_matrix[i-1, j-1].c,
                dtw_matrix[i-1, j].c,
                dtw_matrix[i, j-1].c
            ]
            last_min::Float64 = minimum(tmp)
            dtw_matrix[i, j] = dtw_point(
                cost + last_min, 
                [Pair(i-1, j-1), Pair(i-1, j), Pair(i, j-1)][argmin(tmp)]
            )
        end
    end
    return dtw_matrix
end

function dtw_path(m::Matrix{dtw_point})
    i::Int64, j::Int64 = size(m)[1], size(m)[2]
    result::Vector{Tuple{Int64, Int64}} = [(i-1, j-1)]
    while (i, j) != (1, 1)
        i, j = m[i, j].pre.first, m[i, j].pre.second
        append!(result, [(i-1, j-1)])
    end
    return result[1:end-1]
end
