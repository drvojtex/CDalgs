# CDalgs - Community detection algorithms

## Overview
CDalgs is a framework for communities detection on graphs. The library implements the four following approaches:
1. [Louvain method](https://en.wikipedia.org/wiki/Louvain_method "Louvain method Wikipedia")
2. [CDEP](https://www.sciencedirect.com/science/article/abs/pii/S0020025520310574 "CDEP method ScienceDirect")
3. ModMax method which performs direct maximization of [modularity](https://en.wikipedia.org/wiki/Modularity_(networks) "Modularity Wikipedia") (exponential problem).
4. NCClustering greedy method to finding near clique (dense) subgraphs. 

Furthermore there are implemented two methods to create similarity graphs:
1. Method based on Pearson correlation with usage of [LinRegOutliers](https://juliapackages.com/p/linregoutliers "LinRegOutliers julia package") package (Satman et al., (2021). LinRegOutliers: A Julia package for detecting outliers in linear regression. Journal of Open Source Software, 6(57), 2892, https://doi.org/10.21105/joss.02892).
2. Method based on [Dynamic time warping](https://en.wikipedia.org/wiki/Dynamic_time_warping "DTW Wikipedia") algorithm.

## Example of usage

### Introduction
The simple example of detection of communities on MNIST dataset is presented.

### Codes & commands

The following commands are in also in **exmaples** folder. 

Load libraries.
```julia
julia> using CDalgs
       using MLDatasets
       using LinearAlgebra, StatsBase
       using Graphs, SimpleWeightedGraphs
       using Plots
```

Load dataset & define clustering and graph methods.
```julia
julia> dataset = MNIST(:train).features
       clustering = g -> louvain_clustering(g) # modmax_clustering(g) cdep_clustering(g) nc_clustering(g)
       create_graph = d -> correlation_graph(d)
```

Prepare data and correlation graph.
```julia
julia> n = size(dataset)[1]
julia> data_vec = collect(hcat(
julia> map(x -> vec(x), eachslice(dataset, dims=3))...)')
julia> g = create_graph(data_vec)
```
Perform community detection (graph clustering).
```julia
julia> clusters = clustering(g)
julia> clusters_matrix = transpose(reshape(clusters, (n, n)))
```

Create color map.
```julia
julia> clusters_matrix_colors = fill(RGB(0, 0, 0), (n, n))
julia> colors_vec = map(x->RGB(rand(1)[1], rand(1)[1], rand(1)[1]), 1:length(unique(clusters)))
julia> for i::Int64=1:n for j::Int64=1:n
          clusters_matrix_colors[i, j] = colors_vec[clusters_matrix[i, j]]
       end end
julia> gr(size=(400, 400), html_output_format=:png)
       plot(clusters_matrix_colors)
```

Display clustering of different methods.
```julia
julia> function clusterdataset(g::SimpleWeightedGraph, clustering::Function)
          n::Int64 = sqrt(length(vertices(g)))
          clusters::Vector{Int64} = clustering(g)
          clusters_matrix::Matrix{Int64} = transpose(reshape(clusters, (n, n)))
          clusters_matrix_colors = fill(RGB(0, 0, 0), (n, n))
          colors_vec = map(x->RGB(rand(1)[1], rand(1)[1], rand(1)[1]), 1:length(unique(clusters)))
          for i::Int64=1:n for j::Int64=1:n
             clusters_matrix_colors[i, j] = colors_vec[clusters_matrix[i, j]]
          end end
          clusters_matrix, plot(clusters_matrix_colors, title=String(Symbol(clustering)))
       end
julia> imgs = []
julia> append!(imgs, [clusterdataset(g, louvain_clustering)[2]])
julia> nc_clustering_95(g) = nc_clustering(g, α=.95)
julia> nc_clustering_99(g) = nc_clustering(g, α=.99)
julia> append!(imgs, [clusterdataset(g, nc_clustering_95)[2]])
julia> append!(imgs, [clusterdataset(g, nc_clustering_99)[2]])
```

Plot heatmaps.
```julia
julia> gr(size=(700, 700), html_output_format=:png)
       plot(imgs..., layout=(2, 2))
```

## License

GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
