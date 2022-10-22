
using Graphs, SimpleWeightedGraphs
using DataStructures


"""
    nc_update_community!(g, ranking, community, priorities)

Add the neighbor of current community (which leads to local maximum ranking of the community, 
but the ranking must be greater equal 9/10). In case two ranking-equal new possible communities, 
follow priority vector sorting.

g::SimpleWeightedGraph - given graph.
ranking::Function - function to get ranking of the current community.
community::Vector - current community to be updated.
priorities::Vector - vertices sorted by the priority by which the vertices should be added.
"""
function nc_update_community!(g::SimpleWeightedGraph{S, T}, ranking::Function,
        community::Vector{Int64}, priorities::Vector{Int64}; α::Float64=0.95) where {S<:Integer, T<:Real}

    # vector of neighbors of the community without any community assigment
    N::Vector{Int64} = intersect(
        setdiff(unique(mapreduce(
            x -> SimpleWeightedGraphs.neighbors(g, x), vcat, community
        )), community),
        priorities
    )
    if length(N) == 0 return community end  # if there cannot be added any vertex

    # add the vertex which maximise the ranking function (which result is at least 0.9)
    tmp_communities::Vector{Vector{Int64}} = map(x -> union(community, x), N) 
    new_community::Vector{Int64} = tmp_communities[argmax(map(x -> ranking(x), tmp_communities))]
    return α <= ranking(new_community) ? new_community : community
end

"""
    nc_community(g, v, ranking, priorities; α)

While there can be updated community starting from given vertex v::Int64, expand.

g::SimpleWeightedGraph - given graph.
v::Int64 - starting vertex.
ranking::Function - function to get ranking of the current community.
priorities::Vector - vertices sorted by the priority by which the vertices should be added.
α::Float64 - minimal ranking score of the community.
"""
function nc_community(g::SimpleWeightedGraph{S, T}, v::Int64, 
        ranking::Function, priorities::Vector{Int64}; α::Float64=0.95) where {S<:Integer, T<:Real}

    community = Vector{Int64}([v])
    while true
        l::Int64 = length(community)
        community = nc_update_community!(g, ranking, community, priorities, α=α)
        if l == length(community) return community end
    end
end

"""
    nc_clustering(g; ranking=x->r(x))

Find the near-clique-communities in the given graph g::SimpleWeightedGraph{Int64, Float64} by the 
ranking function (default graph density) and priority sorting (default degree of vertex).

Default ranking is given as:
```
(x::Vector{Int64}, g::SimpleWeightedGraph{Int64, Float64}) -> length(x) == 1 ? 1 : density(g[x])
```
"""
function nc_clustering(g::SimpleWeightedGraph{S, T}; 
        ranking=Nothing, priority=Nothing, α::Float64=0.95) where {S<:Integer, T<:Real}

    if ranking == Nothing
        ranking = x::Vector{Int64} -> length(x) == 1 ? 1 : Graphs.density(g[x])
    end
    if priority == Nothing
        priority = x::Int64 -> sum(g.weights[:,x])
    end

    communities = Set{Set{Int64}}([]) # set of found communities
    used_vertices = Set{Int64}([]) # set of used vertices

    while length(used_vertices) != length(SimpleWeightedGraphs.vertices(g))

        # prioritise vertices which was not used
        priorities::Vector{Int64} = setdiff(SimpleWeightedGraphs.vertices(g), used_vertices)
        sort!(priorities, by=priority, rev=true)

        # find new community
        new_com::Set{Int64} = Set(nc_community(g, priorities[1], ranking, priorities, α=α))
        push!(communities, new_com)
        union!(used_vertices, new_com)

    end

    # create vector of vertices attendace to the communities
    result = zeros(length(SimpleWeightedGraphs.vertices(g)))
    for i::Int64=1:length(communities)
        map(x -> result[x] = Int(i), collect.(communities)[i])
    end

    return Int.(result)
end

nc_clustering(g::SimpleGraph{Int64}) = nc_clustering(SimpleWeightedGraph(g))
