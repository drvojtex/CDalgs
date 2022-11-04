
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

"""
    correlation_graph(data; outfilter=false)

Create correlation graph of the agents by the correlation sreshold smoothness.
The outliers are filtered by the given outfilter method.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, agents, features).
outfilter::Function - method of filtering outliers (default ccf - Minimizing a sum of clipped convex functions).
smoothness::Float64 - treshold of median absolute values of correlations.
"""
function correlation_graph(data::Array{<:AbstractFloat, 3}; 
        outfilter=Nothing, smoothness::Float64=0.3)

    if outfilter == Nothing
        outfilter = ccf
    end

    n = size(data)[2]  # agents count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        
        df::DataFrame = DataFrame(y=data[:, j, :], x=data[:, i, :])
        reg::RegressionSetting = createRegressionSetting(@formula(y~x), df)
        outliers::Vector{Int64} = ccf(reg)["outliers"]
        
        d::Vector{Float64} = diag(cor(
            df[findall(z -> z ∉ outliers, 1:size(df)[1]), :x],
            df[findall(z -> z ∉ outliers, 1:size(df)[1]), :y]
        ))

        if median(abs.(d)) > smoothness
            SimpleWeightedGraphs.add_edge!(g, i, j, median(d))
        end
    end end end
    return g
end
