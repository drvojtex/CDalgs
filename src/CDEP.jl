
using Graphs, SimpleWeightedGraphs

##############################################
# vertex structure

Base.@kwdef mutable struct cdep_vertex
    id::Integer
    neighbors::Dict{Integer, Float64}
    included::Set{Integer} = Set([])
    density::Float64 = 0
    quality::Float64 = 0
    centrality_index::Float64 = 0.0 
    community::Int64 = 0
end

function Base.show(io::IO, v::cdep_vertex)
    v_id::String = string("\033[1;34m vertex id:\033[31m ", v.id, "\n\033[0m")
    ns::String = string("\033[1;34m neighbors:\033[0m ", join(string.(keys(v.neighbors)), " "), "\n")
    
    is::String = string("\033[1;34m included:\033[0m ", join(string.(v.included), " "), "\n")
    is = length(v.included) > 0 ? is : ""
    
    den::String = string("\033[1;34m density:\033[0m ", round(v.density, digits=2), "\n")
    qua::String = string("\033[1;34m quality:\033[0m ", round(v.quality, digits=2), "\n")

    com::String = string("\033[1;34m community id:\033[0m ", v.community, "\n")

    print(io, v_id, ns, is, den, qua, com)
end

##############################################
# Compressing

"""
compress!(g, from, to)

Compress "from" vertex into the "to" vertex.

g::Vector{cdep_vertex} - the graph.
from::Int64 - source vertex to be compressed.
to::Int64 - destination vertex.
"""
function compress!(g::Vector{cdep_vertex}, from::Int64, to::Int64)
    union!(filter(x -> x.id == to, g)[1].included, from, filter(x -> x.id == from, g)[1].included)
    filter!(x -> x.id != from, g)
    map(x -> filter!(y -> y[1] != from, x.neighbors), g)
    nothing
end

"""
find_triangle(g)

Find triangles in the given graph.

g::Vector{cdep_vertex} - the graph.
"""
function find_triangles(g::Vector{cdep_vertex})
    hypotenuse = (x, y) -> x.id ∈ keys(y.neighbors) && y.id ∈ keys(x.neighbors)
    filter(x -> 
        hypotenuse(filter(y -> y.id == collect(x.neighbors)[1][1], g)[1],
            filter(y -> y.id == collect(x.neighbors)[2][1], g)[1])
    , filter(v -> length(v.neighbors) == 2, g))
end

"""
update_triangle!(g, vi, vj, vk)

Compress the triangle defined by vertices vi, vj and vk.

g::Vector{T} - the graph.
vi::T - vertex to be compressed.
vj::T - destination vertex.
vk::T - the "third" vertex in the triangle.
where T<:cdep_vertex
"""
function update_triangle!(g::Vector{T}, vi::T, vj::T, vk::T) where T<:cdep_vertex
    c::Float64 = vj.neighbors[vk.id] + 0.5 * vi.neighbors[vk.id] * vi.neighbors[vj.id]
    g[findall(x -> x.id == vj.id, g)][1].neighbors[vk.id] = c
    g[findall(x -> x.id == vk.id, g)][1].neighbors[vj.id] = c
    compress!(g, vi.id, vj.id)
    nothing
end

"""
compressing!(gc)

Compress given graph (compress vertices of degree 1 and 2).

gc::Vector{cdep_vertex} - the graph to be compressed.
"""
function compressing!(gc::Vector{cdep_vertex})
    
    # compress vertices with degree one
    while any(x -> length(x.neighbors) == 1, gc)
        v::cdep_vertex = sort(filter(x -> length(x.neighbors) == 1, gc),
            by = x -> length(x.included))[1]
        compress!(gc, v.id, first(v.neighbors)[1])
    end

    # compress vertices with degree two
    while length(find_triangles(gc)) > 0
        v::cdep_vertex = sort(find_triangles(gc), by = x -> length(x.included))[1]
        vns::Vector{cdep_vertex} = sort(filter(x -> x.id ∈ keys(v.neighbors), gc), 
            by = x -> length(x.included) + length(x.neighbors), rev=true)
        update_triangle!(gc, v, vns...)
    end
    
    nothing
end

##############################################
# Seeding

"""
vertex_density(v, g)

Compute the density of the given vertex.

v::cdep_vertex - vertex to be density computed. 
g::Vector{cdep_vertex} - original graph before compressing.
"""
function vertex_density!(v::cdep_vertex, g::Vector{cdep_vertex})
    if length(v.neighbors) == 0 && length(v.included) > 1
        original_v::cdep_vertex = filter(x -> x.id == v.id, g)[1]
        v.density = mapreduce(x -> length(x.neighbors), +, 
            filter(y -> y.id ∈ keys(original_v.neighbors), g))/length(original_v.neighbors)
    else
        v.density = length(v.neighbors)
    end
    nothing
end

"""
vertex_quality(v, g)

Compute the quality of the given vertex.

v::cdep_vertex - vertex to be quality computed. 
gc::Vector{cdep_vertex} - graph after compressing.
"""
function vertex_quality!(v::cdep_vertex)
    v.quality = length(v.included)
    nothing
end

"""
compute_indices!(gc)

Compute the density and quality for vertices of the compressed graph.

g::Vector{cdep_vertex} - original graph before seeding.
gc::Vector{cdep_vertex} - compressed graph after the seeding.
"""
function compute_indices!(g::Vector{cdep_vertex}, gc::Vector{cdep_vertex})
    
    map(v::cdep_vertex -> vertex_quality!(v), gc)
    map(v::cdep_vertex -> vertex_density!(v, g), gc)

    max_density::Float64 = maximum(map(x -> x.density, gc))
    max_quality::Float64 = maximum(map(x -> x.quality, gc))
    map(x -> x.density/=max_density, gc)
    map(x -> x.quality/=max_quality, gc)
    map(x -> x.centrality_index = x.quality*x.density, gc)
    nothing
end

"""
seed_determination!(gc)

Determine community seeds of the graph

gc::Vector{cdep_vertex} - graph.
"""
function seed_determination!(gc::Vector{cdep_vertex})
    γ::Vector{Float64} = sort(map(x -> x.centrality_index, gc), rev=true)
    h::Vector{Float64} = []
    for i=1:length(γ)-2
        append!(h, abs((γ[i] - γ[i+1]) - (γ[i+1] - γ[i+2])))
    end
    seeds::Vector{cdep_vertex} = filter(x -> x.centrality_index >= γ[argmax(h)], gc)
    while any(x -> intersect(keys(x.neighbors), map(x -> x.id, seeds)) != Set([]), seeds)
        
        # if there are two seeds that are neighbors, filter one of
        for v1 in seeds
            if intersect(keys(v1.neighbors), map(x -> x.id, seeds)) != Set([])
                filter!(y -> y != v1, seeds)
                break
            end
        end
    end

    for i::Int64=1:length(seeds)
        seeds[i].community = i
    end

    nothing
end

##############################################
# Expansion

"""
simmilarity(vertex, community, g)

Compute the simmilarity between community and vertex.

vertex::Int64 - id of the vertex.
community::Int64 - id of the community.
g::Vector{cdep_vertex} - graph.
"""
function simmilarity(vertex::Int64, community::Int64, g::Vector{cdep_vertex})
    u::cdep_vertex = filter(x -> x.id == vertex, g)[1]

    if u.community == community
        return Inf
    end

    C::Vector{cdep_vertex} = filter(x -> x.community == community, g)
    c_neighbors::Vector{cdep_vertex} = filter(x -> x.id ∈ keys(u.neighbors), C)
    
    if length(c_neighbors) == 0
        return -Inf
    end

    sim_1::Float64 = mapreduce(x -> x.neighbors[u.id], +, c_neighbors)

    sim_2::Float64 = 0
    for v::cdep_vertex in c_neighbors
        for v1::cdep_vertex in filter(x -> x.id ∈ intersect(keys(u.neighbors), keys(v.neighbors)), g)
            v2::Vector{cdep_vertex} = filter(x -> x.id ∈ keys(v1.neighbors), g)
            sim_2 += 1/mapreduce(x -> x.neighbors[v1.id], +, v2)
        end
    end
    
    return sim_1 + sim_2
end

"""
expand!(g)

Assign communities to the vertices by the assigned seeds.

g::Vector{cdep_vertex} - graph with assigned seeds but other vertices without communities assigned.
"""
function expand!(g::Vector{cdep_vertex})
    tmp_g::Vector{cdep_vertex} = deepcopy(g)
    while any(x -> x.community == 0, filter(v -> length(v.neighbors) > 0, g))
        for v::cdep_vertex in filter(x -> x.community == 0, g)
            c_neighbors::Vector{Int64} = filter(z -> z != 0, (unique(map(x -> x.community, 
                filter(y -> y.id ∈ keys(v.neighbors), g)))))
            if length(c_neighbors) > 0
                probs::Vector{Float64} = map(x -> simmilarity(v.id, x, g), c_neighbors)
                if maximum(probs) != -Inf
                    tmp_g[findall(x -> x.id == v.id, tmp_g)][1].community = c_neighbors[argmax(probs)]
                end
            end
        end
        g .= deepcopy(tmp_g)
    end
    nothing
end

"""
propagation(gc, vc)

Assign communities to the vertices by the assigned seeds.

gc::Vector{cdep_vertex} - compressed graph with assigned communities.
vc::Int64 - count of vertices in the original graph.
"""
function propagation(gc::Vector{cdep_vertex}, vc::Int64)
    result::Vector{Int64} = zeros(vc)
    for v::cdep_vertex in gc
        result[v.id] = v.community
        for i::Int64 in v.included
            result[i] = v.community
        end
    end
    return result
end

"""
    cdep_clustering(g)

Find communities by CDEP algorithm for a given graph.

g::SimpleWeightedGraph - graph to be explored.
"""
function cdep_clustering(g::SimpleWeightedGraph)
    cdep_graph::Vector{cdep_vertex} = []
    for v::Int64 in Graphs.vertices(g)
        append!(cdep_graph, [cdep_vertex(
            id=v, 
            neighbors=Dict(Graphs.neighbors(g, v) .=> 
                collect(g.weights[v, Graphs.neighbors(g, v)]))
            )]
        )
    end
    cdep_graph_c = deepcopy(cdep_graph)
    compressing!(cdep_graph_c)
    compute_indices!(cdep_graph, cdep_graph_c)
    seed_determination!(cdep_graph_c)
    if length(filter(v::cdep_vertex -> v.community != 0, cdep_graph_c)) > 1
        expand!(cdep_graph_c)
        propagation(cdep_graph_c, length(Graphs.vertices(g)))
    else
        collect(map(x -> 0, Graphs.vertices(g)))
    end
end

cdep_clustering(g::SimpleGraph{Int64}) = cdep_clustering(SimpleWeightedGraph(g))
