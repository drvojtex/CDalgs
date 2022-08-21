
using Graphs, SimpleWeightedGraphs
using Random, Combinatorics


"""
louvain_update!(c, v, g)

Add vertex to the community to increase modularity.

c::Vector{Int64} - communities vector.
v::Int64 - the vertex to be updated to the community to increase mdularity
g::SimpleWeightedGraph{Int64, Float64} - graph.
"""
function louvain_update!(c::Vector{Int64}, v::Int64, 
        g::SimpleWeightedGraph{S, T}) where {S<:Integer, T<:Real}

    m::Float64 = sum(g.weights)/2

    vec_kᵢ::Vector{Float64} = view(g.weights, v, :)
    kᵢ::Float64 = sum(vec_kᵢ)
    
    K::Float64 = kᵢ/(2*(m^2))
    
    ΔM_max::Float64 = -Inf
    old_c::Vector{Int64} = deepcopy(c)

    for ĉ::Int64 in setdiff(c[SimpleWeightedGraphs.neighbors(g, v)], v)
        C::Vector{Int64} = findall(x -> old_c[x] == ĉ, SimpleWeightedGraphs.vertices(g))
        Σtot::Float64 = sum(view(g.weights, C, :))
        kᵢin::Float64 = sum(view(vec_kᵢ, C))
        ΔM::Float64 = kᵢin/m - Σtot*K
        if ΔM >= ΔM_max
            ΔM_max = ΔM
            c[v] = ĉ
        end
    end
end

"""
    louvain_communities(g)

Find communities on modularity level.

g::SimpleWeightedGraph{Int64, Float64} - graph.
"""
function louvain_communities!(g::SimpleWeightedGraph{S, T}, 
        l::Vector{Vector{Int64}}) where {S<:Integer, T<:Real}
    
    V::Vector = randperm(length(SimpleWeightedGraphs.vertices(g))) 
    c::Vector{Int64} = collect(SimpleWeightedGraphs.vertices(g))
    
    for v::Int64 in V if length(findall(x -> c[x] == c[v], SimpleWeightedGraphs.vertices(g))) == 1 
        louvain_update!(c, v, g) 
        
        tmp_c::Vector{Int64} = map(x->Dict(unique(c) .=> 1:length(unique(c)))[x], c)
        tmp_l::Vector{Int64} = deepcopy(l[end])
        if length(tmp_c) < length(l[end])
            for i::Int64=1:length(tmp_c)
                tmp_l[findall(x->x==i, tmp_l)] .= tmp_c[i]
            end
        else
            tmp_l = deepcopy(tmp_c)
        end
        append!(l, [tmp_l])

    end end
    
    return map(x->Dict(unique(c) .=> 1:length(unique(c)))[x], c)
end

"""
    louvain_hierarchical(g)

Find hierarchical clustering of communities by modularity levels.

g::SimpleWeightedGraph{Int64, Float64} - graph.
"""
function louvain_hierarchical(g::SimpleWeightedGraph{S, T}) where {S<:Integer, T<:Real}
    l::Vector{Vector{Int64}} = [collect(SimpleWeightedGraphs.vertices(g))]
    c::Vector{Int64} = collect(SimpleWeightedGraphs.vertices(g))
    prev_c::Vector{Int64} = zeros(2)
    while length(c) > 1 && prev_c != c
        @show length(c)
        prev_c = deepcopy(c)
        c = louvain_communities!(g, l)
        new_g::SimpleWeightedGraph{Int64, Float64} = SimpleWeightedGraph(length(unique(c)))
        for i::Int64 in unique(c)
            SimpleWeightedGraphs.add_edge!(new_g, i, i, sum(g[findall(x -> x == i, c)].weights))
        end
        for (i, j) in combinations(unique(c), 2)
            c1::Vector{Int64} = findall(x->x==i, c)
            c2::Vector{Int64} = findall(x->x==j, c)
            SimpleWeightedGraphs.add_edge!(new_g, i, j, sum(map(x->x.weight, 
                filter(x -> (x.src ∈ c1 && x.dst ∈ c2) || 
                (x.src ∈ c2 && x.dst ∈ c1), collect(edges(g)))))
            )
        end
        g = deepcopy(new_g)
    end
    return unique(l)
end

"""
    louvain_hierarchical(g)

Local-maxima modularity clustering by louvain algorithm.
Returns vector of communities.

g::SimpleWeightedGraph{Int64, Float64} - graph.
"""
function louvain_clustering(g::SimpleWeightedGraph{S, T}) where {S<:Integer, T<:Real}
    communities::Vector{Vector{Int64}} = louvain_hierarchical(g) 
    communities[argmax(map(c -> Graphs.modularity(g, c; distmx=g.weights), communities))]
end

louvain_clustering(g::SimpleGraph{Int64}) = louvain_clustering(SimpleWeightedGraph(g))
