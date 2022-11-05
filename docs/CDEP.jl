
using DocumentFunction

@doc """
$(DocumentFunction.documentfunction(compress!;
    location=false,
    maintext="Compress 'from' vertex into the 'to' vertex.",
    argtext=Dict("g"=>"the graph",
                 "from"=>"source vertex to be compressed",
                 "to"=>"destination vertex")))
""" compress!

@doc """
$(DocumentFunction.documentfunction(find_triangles;
    location=false,
    maintext="Find triangles in the given graph.",
    argtext=Dict("g"=>"the graph")))
""" find_triangles

@doc """
$(DocumentFunction.documentfunction(update_triangle!;
    location=false,
    maintext="Compress the triangle defined by vertices vi, vj and vk.",
    argtext=Dict("g"=>"the graph",
                 "vi"=>"vertex to be compressed",
                 "vj"=>"destination vertex",
                 "vk"=>"the 'third' vertex in the triangle")))
""" update_triangle!

@doc """
$(DocumentFunction.documentfunction(compressing!;
    location=false,
    maintext="Compress given graph (compress vertices of degree 1 and 2).",
    argtext=Dict("gc"=>"the graph to be compressed")))
""" compressing!

@doc """
$(DocumentFunction.documentfunction(vertex_density!;
    location=false,
    maintext="Compute the density of the given vertex.",
    argtext=Dict("v"=>"vertex to be density computed",
                 "g"=>"original graph before compressing")))
""" vertex_density!

@doc """
$(DocumentFunction.documentfunction(vertex_quality!;
    location=false,
    maintext="Compute the quality of the given vertex.",
    argtext=Dict("v"=>"vertex to be quality computed",
                 "gc"=>"graph after compressing")))
""" vertex_quality!

@doc """
$(DocumentFunction.documentfunction(compute_indices!;
    location=false,
    maintext="Compute the density and quality for vertices of the compressed graph.",
    argtext=Dict("g"=>"original graph before seeding",
                 "gc"=>"compressed graph after the seeding")))
""" compute_indices!

@doc """
$(DocumentFunction.documentfunction(seed_determination!;
    location=false,
    maintext="Determine community seeds of the graph.",
    argtext=Dict("gc"=>"graph")))
""" seed_determination!

@doc """
$(DocumentFunction.documentfunction(simmilarity;
    location=false,
    maintext="Compute the simmilarity between community and vertex.",
    argtext=Dict("vertex"=>"id of the vertex",
                 "vertex"=>"id of the vertex",
                 "community"=>"id of the community",
                 "g"=>"graph")))
""" simmilarity

@doc """
$(DocumentFunction.documentfunction(expand!;
    location=false,
    maintext="Assign communities to the vertices by the assigned seeds.",
    argtext=Dict("g"=>"graph with assigned seeds but other vertices without communities assigned")))
""" expand!

@doc """
$(DocumentFunction.documentfunction(propagation;
    location=false,
    maintext="Assign communities to the vertices by the assigned seeds.",
    argtext=Dict("gc"=>"compressed graph with assigned communities",
                 "vc"=>"count of vertices in the original graph")))
""" propagation

@doc """
$(DocumentFunction.documentfunction(cdep_clustering;
    location=false,
    maintext="Find communities by CDEP algorithm for a given graph.",
    argtext=Dict("g"=>"graph to be explored")))
""" cdep_clustering
