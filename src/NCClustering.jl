
using Graphs, SimpleWeightedGraphs
using DataStructures


function nc_update_community!(g::SimpleWeightedGraph{S, T}, ranking::Function,
        community::Vector{Int64}, priorities::Vector{Int64}; α::Float64=0.95) where {S<:Integer, T<:Real}

    # vector of neighbors of the community without any community assigment
    N::Vector{Int64} = intersect(
        setdiff(unique(mapreduce(
            x -> Graphs.neighbors(g, x), vcat, community
        )), community),
        priorities
    )
    if length(N) == 0 return community end  # if there cannot be added any vertex

    # add the vertex which maximise the ranking function (which result is at least 0.9)
    tmp_communities::Vector{Vector{Int64}} = map(x -> union(community, x), N) 
    new_community::Vector{Int64} = tmp_communities[argmax(map(x -> ranking(x), tmp_communities))]
    return α <= ranking(new_community) ? new_community : community
end

function nc_community(g::SimpleWeightedGraph{S, T}, v::Int64, 
        ranking::Function, priorities::Vector{Int64}; α::Float64=0.95) where {S<:Integer, T<:Real}

    community = Vector{Int64}([v])
    while true
        l::Int64 = length(community)
        community = nc_update_community!(g, ranking, community, priorities, α=α)
        if l == length(community) return community end
    end
end

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
