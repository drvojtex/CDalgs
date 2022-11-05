
using DocumentFunction


@doc """
$(DocumentFunction.documentfunction(wilcoxon;
    location=false,
    maintext="
    Wilcoxon sing-rank non-parametric test to check 
    if the population's median is zero or 
    if the median of diference of two populations zero. 
    
    ```jldoctest
    b::Bool, W::Int64, z::Float64 = wilcoxon(xydiff::Vector{<:AbstractFloat})
    b::Bool, W::Int64, z::Float64 = wilcoxo(X::Vector{<:AbstractFloat}, Y::Vector{<:AbstractFloat})
    ```

    where 'W' is W-value, 'z' is z-score and 'b' is the test result for the First type error 0.05. 
    When 'b' is true, the populations 'X' and 'Y' have got the same median (or the diference has median about zero).

    ",
    argtext=Dict("xydiff"=>"population or differece of two populations",
                 "X"=>"population",
                 "Y"=>"population")))
""" wilcoxon

@doc """
$(DocumentFunction.documentfunction(correlation_graph;
    location=false,
    maintext="
    2-D case:
        Create correlation graph of statistically significant 
        correlations (Correlation t-test) of the agents at the given level of significance.

    3-D case:
        Create correlation graph of the agents by the correlation treshold smoothness.
        The outliers are filtered by the given outfilter method.
    ",
    argtext=Dict("data (2-D case)"=>"data matrix shape(batch, agents)",
                 "α"=>"level of significance (default 0.05)",
                 "data (3-D case)"=>"data matrix shape(batch, agents, features)",
                 "outfilter"=>"method of filtering outliers (default ccf - Minimizing a sum of clipped convex functions)",
                 "smoothness"=>"treshold of median absolute values of correlations")))
                 
""" correlation_graph
