
using FeaturesRelevance
using MLDatasets
using LinearAlgebra, StatsBase
using Graphs, SimpleWeightedGraphs
using Plots


function clusterdataset(dataset::T, clustering::Function,
         graph::Function) where T<:AbstractArray

    n::Int64 = size(dataset)[1]

    data_vec::Matrix = collect(hcat(
        map(x -> vec(x), eachslice(dataset, dims=3))...
    )')
    
    g::SimpleWeightedGraph = graph(data_vec)

    clusters::Vector{Int64} = clustering(g)
    clusters_matrix::Matrix{Int64} = transpose(reshape(clusters, (n, n)))

    clusters_matrix_colors = fill(RGB(0, 0, 0), (n, n))
    colors_vec = map(x->RGB(rand(1)[1], rand(1)[1], rand(1)[1]), 1:length(unique(clusters)))
    for i::Int64=1:n for j::Int64=1:n
        clusters_matrix_colors[i, j] = colors_vec[clusters_matrix[i, j]]
    end end
    plot(clusters_matrix_colors)
end

trn_nc = []
tst_nc = []
for i=0:9
    append!(trn_nc, [clusterdataset(MNIST(:train).features[:,:,findall(x->x==i, MNIST(:train).targets)], g->nc_clustering(g), d->correlation_graph(d))])
    append!(tst_nc, [clusterdataset(MNIST(:test).features[:,:,findall(x->x==i, MNIST(:test).targets)], g->nc_clustering(g), d->correlation_graph(d))])
end
append!(trn_nc, [clusterdataset(MNIST(:train).features, g->nc_clustering(g), d->correlation_graph(d))])
append!(tst_nc, [clusterdataset(MNIST(:test).features, g->nc_clustering(g), d->correlation_graph(d))])

trn_lc = []
tst_lc = []
for i=0:9
    append!(trn_lc, [clusterdataset(MNIST(:train).features[:,:,findall(x->x==i, MNIST(:train).targets)], g->louvain_clustering(g), d->correlation_graph(d))])
    append!(tst_lc, [clusterdataset(MNIST(:test).features[:,:,findall(x->x==i, MNIST(:test).targets)], g->louvain_clustering(g), d->correlation_graph(d))])
end
append!(trn_lc, [clusterdataset(MNIST(:train).features, g->louvain_clustering(g), d->correlation_graph(d))])
append!(tst_lc, [clusterdataset(MNIST(:test).features, g->louvain_clustering(g), d->correlation_graph(d))])
