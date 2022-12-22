
using Graphs, SimpleWeightedGraphs
using LinearAlgebra, LinRegOutliers
using Statistics, HypothesisTests, DataFrames
using ThreadTools

#=
function wilcoxon(xydiff::Vector{<:AbstractFloat})
    if length(xydiff) == 0 return true end
    df = DataFrame(diff = xydiff, absdiff = abs.(xydiff))
    df[!, :sgn] = sign.(df[!, :diff])
    df[!, :Rᵢ] = 1:length(df[!, :diff])
    W::Int64 = min(sum(filter(x->x.sgn==-1, df)[!, :Rᵢ]), sum(filter(x->x.sgn==1, df)[!, :Rᵢ]))
    z::Float64 = mapreduce(xy->xy[1]*xy[2], +, zip(df[!,:sgn], df[!,:Rᵢ]))
    N::Int64 = size(df)[1]
    z = z/sqrt(N*(N+1)*(2*N+1)/6)
    b::Bool = abs(z) <= 1.96
    return b, W, z
end

function wilcoxon(X::Vector{<:AbstractFloat}, Y::Vector{<:AbstractFloat})
    wilcoxon(filter(x->x!=0, X.-Y))
end

function correlation_graph(data::Matrix{<:AbstractFloat}; α::Float64=.05)
    n = size(data)[2]  # agents count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        if isnan(cor(data[:,i], data[:,j]))
            if wilcoxon(data[:, i] .- data[:, j])[1]
                SimpleWeightedGraphs.add_edge!(g, i, j, 1.0)
            end
        else
            p::Float64 = pvalue(CorrelationTest(data[:,i], data[:,j]))
            if p <= α SimpleWeightedGraphs.add_edge!(g, i, j, cor(data[:,i], data[:,j])) end
        end
    end end end
    return g
end

function correlation_graph(data::Array{<:AbstractFloat, 3}; 
        outfilter=Nothing, smoothness::Float64=0.3)

    if outfilter == Nothing
        outfilter = ccf
    end

    n = size(data)[2]  # agents count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        
        d::Vector{Float64} = []

        for k=1:size(data)[3]
            df::DataFrame = DataFrame(y=data[:, j, k], x=data[:, i, k])
            reg::RegressionSetting = createRegressionSetting(@formula(y~x), df)
            outliers::Vector{Int64} = outfilter(reg)["outliers"]
        
            append!(d, cor(
                    df[findall(z -> z ∉ outliers, 1:size(df)[1]), :x],
                    df[findall(z -> z ∉ outliers, 1:size(df)[1]), :y]
                )
            )
        end

        if median(abs.(d)) > smoothness
            SimpleWeightedGraphs.add_edge!(g, i, j, median(d))
        end
    end end end
    return g
end

=#

function dtw_graph(data::Array{<:AbstractFloat, 3})

    n = size(data)[2]  # agents count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)

    function incr_edge!(g::SimpleWeightedGraph, v1::Integer, v2::Integer)
        if SimpleWeightedGraphs.has_edge(g, v1, v2)
            g.weights[v1, v2] += 1
            g.weights[v2, v1] += 1
        else
            SimpleWeightedGraphs.add_edge!(g, v1, v2, 1)
        end
    end

    for i=1:n for j=1:i if i != j
        
        path::Vector{Tuple{Int64, Int64}} = dtw_path(dtw(data[j, :, :], data[i, :, :]))
        for p in path
            incr_edge!(g, p[1], p[2])
        end
        
    end end end
    return g
end
