
using Graphs, SimpleWeightedGraphs
using Random


function modmax_update!(c::Vector, v::Int64,
        g::SimpleWeightedGraph{S, T}) where {S<:Integer, T<:Real}
    
    # modularity before assignation
    Q::Number = Graphs.modularity(g, c, distmx=g.weights)
    ΔQ_max = 0
    
    # iterate over all neighbors of given vertex 'v'
    for n in SimpleWeightedGraphs.neighbors(g, v)
        tmp_c::Vector = deepcopy(c)
        if length(findall(x->c[x]==c[n], 
                SimpleWeightedGraphs.vertices(g))) == 1  # neighbor does not have community
            tmp_c[n] = maximum(c) + 1
        end
        # assing to neighbor's community
        tmp_c[v] = tmp_c[n]
        
        #= compute change of modularity after assignation of the given vertex 'v'
            to the community of it's neighbor 'n'
        =#
        ΔQ::Number = Graphs.modularity(g, tmp_c, distmx=g.weights) - Q
        # update maximum change of modularity and new communities-vector
        if ΔQ_max < ΔQ
            ΔQ_max = ΔQ
            c .= deepcopy(tmp_c)
        end
    end
end

function modmax_clustering(g::SimpleWeightedGraph)
    V::Vector = randperm(length(SimpleWeightedGraphs.vertices(g))) 
    c::Vector{Int64} = collect(SimpleWeightedGraphs.vertices(g))
    while true
        old_c = deepcopy(c)
        for v in V modmax_update!(c, v, g) end
        if old_c == c break end  # If there is no change, break loop.
        randperm!(V)  # New random permutation of vertices to be explored.
    end
    map(x->Dict(unique(c) .=> 1:length(unique(c)))[x], c)
end
