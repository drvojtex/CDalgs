
module FeaturesRelevance

include("SimmilarityGraphs.jl")
include("Louvain.jl")
include("ModularityMaximization.jl")
include("NCClustering.jl")
include("Visualise.jl")

export correlation_graph
export nc_clustering, modmax_clustering, louvain_clustering
export gml

end
