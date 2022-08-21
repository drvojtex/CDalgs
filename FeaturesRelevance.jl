
module FeaturesRelevance

include("src/CorrelationGraph.jl")
include("src/Louvain.jl")
include("src/ModularityMaximization.jl")
include("src/NCClustering.jl")
include("src/Visualise.jl")

export correlation_graph
export nc_clustering, modmax_clustering, louvain_clustering
export gml

end
