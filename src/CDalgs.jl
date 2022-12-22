
module CDalgs

include("SimmilarityGraphs.jl")
include("Louvain.jl")
include("ModMax.jl")
include("NCClustering.jl")
include("CDEP.jl")
include("Visualise.jl")
include("DTW.jl")

include("../docs/CDEP.jl")
include("../docs/Louvain.jl")
include("../docs/ModMax.jl")
include("../docs/NCClustering.jl")
include("../docs/SimmilarityGraphs.jl")
include("../docs/Visualise.jl")

export dtw_graph
export nc_clustering, modmax_clustering, louvain_clustering, cdep_clustering
export gml
export dtw_point, dtw, dtw_path

end
