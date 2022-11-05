
using DocumentFunction

@doc """
$(DocumentFunction.documentfunction(nc_update_community!;
    location=false,
    maintext="
    Add the neighbor of current community (which leads to local maximum ranking of the community, 
    but the ranking must be greater equal 9/10). In case two ranking-equal new possible communities, 
    follow priority vector sorting.
    ",
    argtext=Dict("g"=>"given graph",
                 "ranking"=>"function to get ranking of the current community",
                 "community"=>"current community to be updated",
                 "priorities"=>"vertices sorted by the priority by which the vertices should be added")))
""" nc_update_community!

@doc """
$(DocumentFunction.documentfunction(nc_community;
    location=false,
    maintext="While there can be updated community starting from given vertex v::Int64, expand.",
    argtext=Dict("g"=>"given graph",
                 "v"=>"starting vertex"),
    keytext=Dict("ranking"=>"function to get ranking of the current community",
                 "priorities"=>"vertices sorted by the priority by which the vertices should be added",
                 "α"=>"minimal ranking score of the community")))
""" nc_community

@doc """
$(DocumentFunction.documentfunction(nc_clustering;
    location=false,
    maintext="
    Find the near-clique-communities in the given graph g::SimpleWeightedGraph{Int64, Float64} by the 
    ranking function (default graph density) and priority sorting (default degree of vertex).
    
        Default ranking is given as:
        ```
        (x::Vector{Int64}, g::SimpleWeightedGraph{Int64, Float64}) -> length(x) == 1 ? 1 : density(g[x])
        ```
    ",
    argtext=Dict("g"=>"given graph"),
    keytext=Dict("ranking"=>"function to get ranking of the current community",
                 "priorities"=>"vertices sorted by the priority by which the vertices should be added",
                 "α"=>"minimal ranking score of the community")))
""" nc_clustering
