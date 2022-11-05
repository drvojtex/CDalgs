
using DocumentFunction


@doc """
$(DocumentFunction.documentfunction(gml;
    location=false,
    maintext="Export the graph defined by fadjlist to the gml format and assigne colors by the communities vector.
        e.g. communities:
        [[1,2], [3, 4], [5]]
        is equal to
        [1, 1, 2, 2, 3]      
        
    Communities are stored as 'vector of communities vectors' or as 'vector of vertices assigments to the communities'.
    ",
    argtext=Dict("fadjlist"=>"vector of neighbors vectors for each vertex",
                 "communities::Vector{Vector{<:Real}}"=>"",
                 "communities::Vector{<:Real}"=>"",
                 "path"=>"path to the *.gml file")))
                 
""" gml
