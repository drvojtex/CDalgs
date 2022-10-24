
using Graphs, SimpleWeightedGraphs
using LinearAlgebra, LinRegOutliers
using Statistics, HypothesisTests, DataFrames
using ThreadTools


@doc """
    Wilcoxon sing-rank non-parametric test to check 
    if the population's median is zero. 
    # Examples
    ```jldoctest
    b::Bool, W::Int64, z::Float64 = wilcoxon(xydiff::Vector{<:AbstractFloat})
    b::Bool, W::Int64, z::Float64 = wilcoxo(X::Vector{<:AbstractFloat}, Y::Vector{<:AbstractFloat})
    ```
    where 'W' is W-value, 'z' is z-score and 'b' is the test result for the First type error 0.05. 
    When 'b' is true, the populations 'X' and 'Y' have got the same median (or the diference has median about zero).
    """ ->
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

"""
    correlation_graph(data; α=.05)

Create correlation graph of statistically significant 
correlations (Correlation t-test) of the agents at the given level of significance.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, agents).
α::Float64=.05 - level of significance (default 0.05).
"""
function correlation_graph(data::Matrix{<:AbstractFloat}; α::Float64=.05)
    n = size(data)[2]  # agents count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        if isnan(cor(data[:,i], data[:,j]))
            data_diff::Vector{Float64} = data[:, i] .- data[:, j]
            if wilcoxon(data_diff)[1]
                df::DataFrame = DataFrame(y=data_diff, x=1:length(data_diff))
                reg::RegressionSetting = createRegressionSetting(@formula(y~x), df)
                outliers::Vector{Int64} = bch(reg)["outliers"]
                deleteat!(data_diff, outliers)
                if wilcoxon(data_diff)[1]
                    SimpleWeightedGraphs.add_edge!(g, i, j, 1.0)
                end 
            end
        else
            p::Float64 = pvalue(CorrelationTest(data[:,i], data[:,j]))
            if p <= α SimpleWeightedGraphs.add_edge!(g, i, j, cor(data[:,i], data[:,j])) end
        end
    end end end
    return g
end

"""
    correlation_graph(data; α=.05)

Create correlation graph of statistically significant 
correlations of the agents at the given level of significance 0.05. 
The outliers are of correlation are filtered by Billor & Chatterjee & Hadi method.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, agents, features).
"""
function correlation_graph(data::Array{<:AbstractFloat, 3})
    n = size(data)[2]  # agents count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        d::Vector{Float64} = diag(cor(data[:, i, :], data[:, j, :]))
        if !wilcoxon(d)[1]
            df::DataFrame = DataFrame(y=d, x=1:length(d))
            reg::RegressionSetting = createRegressionSetting(@formula(y~x), df)
            outliers::Vector{Int64} = bch(reg)["outliers"]
            deleteat!(d, outliers)
            if !wilcoxon(d)[1]
                SimpleWeightedGraphs.add_edge!(g, i, j, median(d))
            end
        end
    end end end
    return g
end
