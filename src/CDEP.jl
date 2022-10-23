
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
g::Vector{cdep_vertex} - original graph before seeding.
"""
function vertex_density!(v::cdep_vertex, g::Vector{cdep_vertex})
    if length(v.neighbors) == 0 && length(v.included) > 1
        original_v::cdep_vertex = filter(x -> x.id == v.id, g)[1]
        v.density = mapreduce(x -> length(x.neighbors), +, 
            filter(y -> y.id ∈ original_v.neighbors, g))/length(original_v)
    else
        v.density = length(v.neighbors)
    end
    nothing
end

"""
vertex_quality(v, g)

Compute the quality of the given vertex.

v::cdep_vertex - vertex to be quality computed. 
g::Vector{cdep_vertex} - original graph before seeding.
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
    for v::cdep_vertex in gc
        vertex_quality!(v)
        vertex_density!(v, g)
    end
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
        for v1 in seeds 
            filter!(x -> intersect(keys(x.neighbors), map(x -> x.id, seeds)) == Set([]), seeds)
        end
    end

    for i::Int64=1:length(seeds)
        seeds[i].community = i
    end
end

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

g = [
    cdep_vertex(id=1, neighbors=Dict(2=>1)), 
    cdep_vertex(id=2, neighbors=Dict(1=>1, 3=>1, 4=>1)), 
    cdep_vertex(id=3, neighbors=Dict(2=>1, 4=>1, 5=>1, 6=>1)), 
    cdep_vertex(id=4, neighbors=Dict(2=>1, 3=>1, 5=>1, 6=>1, 7=>1)), 
    cdep_vertex(id=5, neighbors=Dict(3=>1, 4=>1, 6=>1)),
    cdep_vertex(id=6, neighbors=Dict(3=>1, 4=>1, 5=>1, 9=>1)),
    cdep_vertex(id=7, neighbors=Dict(4=>1, 8=>1)),
    cdep_vertex(id=8, neighbors=Dict(7=>1, 9=>1, 11=>1)),
    cdep_vertex(id=9, neighbors=Dict(6=>1, 8=>1, 10=>1, 12=>1, 13=>1)),
    cdep_vertex(id=10, neighbors=Dict(9=>1, 11=>1, 12=>1)),
    cdep_vertex(id=11, neighbors=Dict(8=>1, 10=>1, 12=>1)),
    cdep_vertex(id=12, neighbors=Dict(9=>1, 10=>1, 11=>1, 13=>1)),
    cdep_vertex(id=13, neighbors=Dict(9=>1, 12=>1, 14=>1)),
    cdep_vertex(id=14, neighbors=Dict(13=>1, 15=>1)),
    cdep_vertex(id=15, neighbors=Dict(14=>1))
]
gc = deepcopy(g)
compressing!(gc)
compute_indices!(g, gc)
seed_determination!(gc)
for id in map(x->x.id, gc)
    @show id, simmilarity(id, 1, gc), simmilarity(id, 2, gc)
end