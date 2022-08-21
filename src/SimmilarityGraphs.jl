
using Graphs, SimpleWeightedGraphs
using Statistics, HypothesisTests


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

"""
    wilcoxon_graph(data; α=.05)

Create correlation graph of statistically significant 
correlations at the given level of significance.

data::Matrix{<:AbstractFloat} - data matrix shape(batch, features).
α::Float64=.05 - level of significance (default 0.05).
"""
function wilcoxon_graph(data::Matrix{<:AbstractFloat}; α::Float64=.05)
    n = size(data)[2]  # features count
    g::SimpleWeightedGraph{Int64} = SimpleWeightedGraph(n)
    for i=1:n for j=1:i if i != j
        p::Float64 = pvalue(CorrelationTest(data[:,i], data[:,j]))
        if p <= α SimpleWeightedGraphs.add_edge!(g, i, j, cor(data[:,i], data[:,j])) end
    end end end
    return g
end
