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

### Codes & commands

The following commands are in also in **exmaples** folder. 

```julia
julia> using Flux, IterTools
       using HypothesisTests, StatsBase, Statistics, Random, LinearAlgebra
       using DataFrames, Graphs, SimpleWeightedGraphs
       using Maen, CDalgs
       using MLDatasets: BostonHousing
       using Logging
```

## License

GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
