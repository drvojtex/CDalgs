
using Graphs, SimpleWeightedGraphs
using Statistics, HypothesisTests, DataFrames
using ThreadTools


@doc """
    Wilcoxon sing-rank non-parametric test to check if two populations have the 
    same median. 
    # Examples
    ```jldoctest
    W::Int64, z::Float64, b::Bool = wilcoxon(X::Vector{Float64}, Y::Vector{Float64})
    ```
    where 'W' is W-value, 'z' is z-score and 'b' is the test result for the First type error 0.05. 
    When 'b' is true, the populations 'X' and 'Y' have got the same median.
    """ ->
function wilcoxon(X::Vector{<:AbstractFloat}, Y::Vector{<:AbstractFloat})
    xydiff::Vector{<:AbstractFloat} = filter(x->x!=0, X.-Y) 
    if length(xydiff) == 0 true end
    df = DataFrame(diff = xydiff, absdiff = abs.(xydiff))
    df[!, :sgn] = sign.(df[!, :diff])
    df[!, :Rᵢ] = 1:length(df[!, :diff])
    #W::Int64 = min(sum(filter(x->x.sgn==-1, df)[!, :Rᵢ]), sum(filter(x->x.sgn==1, df)[!, :Rᵢ]))
    z::Float64 = mapreduce(xy->xy[1]*xy[2], +, zip(df[!,:sgn], df[!,:Rᵢ]))
    N::Int64 = size(df)[1]
    z = z/sqrt(N*(N+1)*(2*N+1)/6)
    return abs(z) <= 1.96
end

"""
    correlation_graph(data; α=.05)

Create correlation graph of statistically significant 
correlations at the given level of significance.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, features).
α::Float64=.05 - level of significance (default 0.05).
"""
function mycorrelation_graph(data::Matrix{<:AbstractFloat}; α::Float64=.05)
    n = size(data)[2]  # features count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        if isnan(cor(data[:,i], data[:,j]))
            if wilcoxon(data[:, i], data[:, j])
                SimpleWeightedGraphs.add_edge!(g, i, j, 1.0)
            end
        else
            p::Float64 = pvalue(CorrelationTest(data[:,i], data[:,j]))
            if p <= α SimpleWeightedGraphs.add_edge!(g, i, j, cor(data[:,i], data[:,j])) end
        end
    end end end
    return g
end
