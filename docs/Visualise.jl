
using DocumentFunction


@doc """
$(DocumentFunction.documentfunction(gml;
    location=false,
    maintext="Export the graph defined by fadjlist to the gml format and assigne colors by the communities vector.
        e.g. communities:
        [[1,2], [3, 4], [5]]
        is equal to
        [1, 1, 2, 2, 3]            
    ",
    argtext=Dict("fadjlist"=>"vector of neighbors vectors for each vertex",
                 "communities::Vector{Vector{<:Real}}"=>"vector of communities vectors",
                 "communities::Vector{<:Real}"=>"vector of vertices assigments to the communities",
                 "path"=>"path to the *.gml file")))
                 
""" gml
