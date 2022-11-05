
using DocumentFunction

@doc """
$(DocumentFunction.documentfunction(louvain_update!;
    location=false,
    maintext="Add vertex to the community to increase modularity.",
    argtext=Dict("c"=>"communities vector",
                 "v"=>"the vertex to be updated to the community to increase mdularity",
                 "g"=>"graph")))
""" louvain_update!

@doc """
$(DocumentFunction.documentfunction(louvain_communities!;
    location=false,
    maintext="Find communities on modularity level.",
    argtext=Dict("g"=>"graph")))
""" louvain_communities!

@doc """
$(DocumentFunction.documentfunction(louvain_hierarchical;
    location=false,
    maintext="Find hierarchical clustering of communities by modularity levels.",
    argtext=Dict("g"=>"graph")))
""" louvain_hierarchical

@doc """
$(DocumentFunction.documentfunction(louvain_clustering;
    location=false,
    maintext="Local-maxima modularity clustering by louvain algorithm. 
              Returns vector of communities.",
    argtext=Dict("g"=>"graph")))
""" louvain_clustering
