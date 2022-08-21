
using FeaturesRelevance
using MLDatasets
using LinearAlgebra, StatsBase
using Graphs, SimpleWeightedGraphs
using Plots


function clusterdataset(dataset::T, clustering::Function,
         graph::Function) where T<:AbstractArray

    n::Int64 = size(dataset)[1]

    data_vec::Matrix = collect(hcat(
        map(x -> vec(x), eachslice(dataset.+10e-20, dims=3))...
    )')
    
    g::SimpleWeightedGraph = graph(data_vec)
    clusters::Vector{Int64} = clustering(g)    
    clusters_matrix::Matrix{Int64} = reshape(clusters, (n, n))

    clusters_matrix_colors = fill(RGB(0, 0, 0), (n, n))
    colors_vec = map(x->RGB(rand(1)[1], rand(1)[1], rand(1)[1]), 1:length(unique(clusters)))
    for i::Int64=1:n for j::Int64=1:n
        clusters_matrix_colors[i, j] = colors_vec[clusters_matrix[i, j]]
    end end
    plot(clusters_matrix_colors)
end

p1 = clusterdataset(MNIST(:train).features, g->louvain_clustering(g), d->correlation_graph(d))
p2 = clusterdataset(MNIST(:test).features, g->louvain_clustering(g), d->correlation_graph(d))

plot(p1, p2, layout = (1, 2), legend = false)
