
using DocumentFunction

@doc """
$(DocumentFunction.documentfunction(modmax_update!;
    location=false,
    maintext="Update vertex community to increase modularity.",
    argtext=Dict("c"=>"communities vector",
                 "v"=>"the vertex to be updated to the community to increase mdularity",
                 "g"=>"graph")))
""" modmax_update!

@doc """
$(DocumentFunction.documentfunction(modmax_clustering;
    location=false,
    maintext="Find the communities for which has that division the maxmimal modularity.

                A random permutation of the vertices of the graph is traversed, 
                with the currently iterating vertex being assigned to the community 
                so that the modularity of the graph is locally maximized. The algorithm 
                stops at the moment when changing the community of even one vertex 
                does not lead to the growth of modularity.
        ",
    argtext=Dict("g"=>"graph")))
""" modmax_clustering
