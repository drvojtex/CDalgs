
using Graphs, SimpleWeightedGraphs
using Statistics, HypothesisTests, DataFrames


"""
    correlation_graph(data; α=.05)

Create correlation graph of statistically significant 
correlations at the given level of significance.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, features).
α::Float64=.05 - level of significance (default 0.05).
"""
function correlation_graph(data::Matrix{<:AbstractFloat}; α::Float64=.05)
    n = size(data)[2]  # features count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        p::Float64 = pvalue(CorrelationTest(data[:,i], data[:,j]))
        if p <= α SimpleWeightedGraphs.add_edge!(g, i, j, cor(data[:,i], data[:,j])) end
    end end end
    return g
end

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
    xydiff::Vector{Float64} = filter(x->x!=0, X.-Y) 
    df = DataFrame(diff = xydiff, absdiff = abs.(xydiff))
    sort!(df, [order(:absdiff)])
    df[!, :sgn] = sign.(df[!, :diff])
    df[!, :Rᵢ] = 1:length(df[!, :diff])
    W::Int64 = min(sum(filter(x->x.sgn==-1, df)[!, :Rᵢ]), 
                    sum(filter(x->x.sgn==1, df)[!, :Rᵢ]))
    z::Float64 = mapreduce(xy->xy[1]*xy[2], +, zip(df[!,:sgn], df[!,:Rᵢ]))
    N::Int64 = size(df)[1]
    z = z/sqrt(N*(N+1)*(2*N+1)/6)
    return W, z, abs(z) <= 1.96
end

"""
    wilcoxon_graph(data; α=.05)

Create the graph of statistically significant 
differences of medians at the given level of significance.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, features).
"""
function wilcoxon_graph(data::Matrix{<:AbstractFloat})
    n = size(data)[2]  # features count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        _, _, b::Bool = wilcoxon(data[:,i], data[:,j])
        if b
            SimpleWeightedGraphs.add_edge!(g, i, j, abs(median(data[:,i]) - median(data[:,j]))) 
    end end end end
    m::Float64 = maximum(g.weights)
    for i=1:n for j=1:i if i != j if Graphs.has_edge(g, i, j) 
        g.weights[i, j] = m - g.weights[i, j] + 0.001
    end end end end
    return g
end
