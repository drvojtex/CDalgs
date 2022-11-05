
using Erdos
using Plots


function gml(fadjlist::T, communities::T, path::String) where T<:Vector{Vector{U}} where U<:Real
    
        edge_in_component = (x, y) -> length(filter(xy-> x ∈ xy && y ∈ xy, communities)) > 0
    
    g = Erdos.Network(length(fadjlist))
    edges = fill(:([fill "#000000"]), Int(mapreduce(x->length(x),+,fadjlist)/2))
    
    idx::Int64 = 0
    done_idxs = []
    for i in eachindex(fadjlist)
        for j in fadjlist[i]
            if (i, j) ∉ done_idxs && (j, i) ∉ done_idxs
                Erdos.add_edge!(g, i, j)
                idx += 1
                append!(done_idxs, [(i, j)])
                if edge_in_component(i, j) edges[idx] = :([width 4 fill "#000000"]) end
    end end end

    Erdos.vprop!(g, "label", VertexMap(g, ["$i" for i in eachindex(fadjlist)]))

    colors::Vector{Expr} = fill(:([fill "#000000"]), length(fadjlist))
    for i in eachindex(communities)
        for j in communities[i]
            c::String = string(
                "#"*hex(RGB(cgrad(:thermal, length(communities)+1, categorical = true)[i+1])),
                "d9"
            )
            colors[j] = :([fill $c])
    end end
    Erdos.vprop!(g, "graphics", VertexMap(g, colors))

    Erdos.eprop!(g, "graphics", EdgeMap(g, edges))

    Erdos.writenetwork("$path", g)
end

function gml(fadjlist::T, communities::Vector{U}, path::String) where T<:Vector{Vector{U}} where U<:Real
    c::Vector = []
    for i::Int64 in unique(communities)
        append!(c, [findall(x -> x == i, communities)])
    end    
    gml(fadjlist, c, path)
end
