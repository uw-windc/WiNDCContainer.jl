"""
    WiNDCtable

Abstract supertype for all WiNDCtables. 

## Required Fields

- `table::DataFrame`: The main table of the WiNDCtable.
- `sets::DataFrame`: The sets of the WiNDCtable.

## Required Functions

- `domain(data::T) where T<:WiNDCtable`: [`domain`](@ref)


To Do:

Add general idea of how this works.
"""
abstract type WiNDCtable end;



function (::Type{T})(
        data::DataFrame, 
        sets::DataFrame, 
        elements::DataFrame;
        regularity_check::Bool = true
    ) where T <: WiNDCtable
    
    X = T(data, sets, elements)

    if regularity_check
        regularity(X)
    end
    return X
end

"""

Add type checking on columns
"""
function regularity(X::T) where T <: WiNDCtable
    # Extract fields and ensure function implemented
    data = table(X)
    SETS = sets(X)
    ELEMENTS = elements(X)

    # Ensure all dataframes have the correct columns
    Symbol.(names(data)) == [domain(X); [:parameter, :value]] || error("Data names do not match expected names: $(Symbol.(names(data))) != $([domain(X); [:parameter, :value]])")
    Symbol.(names(SETS)) == [:name, :description, :domain] || error("Sets DataFrame names do not match expected names: $(Symbol.(names(SETS))) != [:name, :description, :domain]")
    Symbol.(names(ELEMENTS)) == [:name, :description, :set, :parameter] || error("Elements DataFrame names do not match expected names: $(Symbol.(names(ELEMENTS))) != [:name, :description, :set]")

    all(x∈[domain(X);[:parameter]] for x in unique(SETS[!, :domain])) || error("Found domain(s) in sets that is not in the domain: $([x for x in unique(SETS[!, :domain]) if !(x in domain(X))])")
    set_names = SETS[!, :name]
    all(x∈set_names for x in unique(ELEMENTS[!, :set])) || error("Found set(s) in elements that are not set(s): $([x for x in unique(ELEMENTS[!, :set]) if !(x in set_names)])")

    for d in [domain(X)..., :parameter]
        elms = unique(data[!,d])
        sets_in_domain = SETS[SETS.domain .== d, :name]
        all_elements = elements(X, sets_in_domain...)[!, :name]
        all(x -> x in all_elements, elms) || error("Found entry in column `$d` that are not elements: $([x for x in elms if !(x in all_elements)])")
    end
end


"""
    domain(data::T) where T<:WiNDCtable
    domain(data::WiNDCtable, set_name::Symbol) 

Return the domain of the WiNDCtable object. Must be implemented for any subtype 
of WiNDCtable. Will throw an error if not implemented.

## Required Arguments

1. `data` - A WiNDCtable-like object.

## Output

Returns a vector of symbols representing the domain of the WiNDCtable object.


!!! note
    This function must be implemented for any subtype of WiNDCtable.
"""
domain(data::WiNDCtable) = throw(ArgumentError("domain not implemented for WiNDCtable"))
function domain(data::WiNDCtable, set_name::Symbol) 
     
    set_names = subset(sets(data), :name => ByRow(==(set_name)))

    if :parameter in set_names[!,:domain]
        return :parameter
    else
        return set_names[1,:domain]
    end
end
domain(data::WiNDCtable, set_element::Pair{Symbol, T}) where T <: Any = domain(data, set_element[1]) 




"""
    table(data::WiNDCtable)
    table(data::WiNDCtable, set_name::Symbol)
    table(data::WiNDCtable, set_element::Pair{Symbol, T}) where T <: Any
    table(data::WiNDCtable, set_element::Pair{Symbol, Vector{T}}) where T <: Any
    table(data, set_names...)

Return the main table of a WiNDCtable object. Optionally filter by set name or set
element pair.

## Examples

```julia
julia> table(data) # Returns the entire table of the WiNDCtable object
julia> table(data, :commodity) # Returns the table filtered by the 'commodity' set
julia> table(data, :commodity => ["111CA", "222CA"]) # Returns the table filtered by the 'commodity' set with elements "111CA" and "222CA"
julia> table(data, :commodity => Symbol("111CA"), :sector) # Returns the table filtered by the 'commodity' set with element "111CA" and the 'sector' set
```

!!! note
    `table(data::WiNDCtable)` must be implemented for any subtype of WiNDCtable.
    The expected output is the entire `data` DataFrame.
"""
table(data::WiNDCtable) = throw(ArgumentError("table not implemented for WiNDCtable"))
function table(data::WiNDCtable, Domain::Symbol, elements::Vector{T}; column = :value, output=:value) where T <: Any
    return subset(table(data), Domain => ByRow(∈(elements))) |> x -> select(x, domain(data)..., :parameter, column => output)
end


function table(data::WiNDCtable, set_name::Symbol; column = :value, output=:value)
    E = elements(data, set_name)[!, :name]
    d = domain(data, set_name)
    return table(data, d, E; column = column, output = output)
end


function table(data::WiNDCtable, set_element::Pair{Symbol, T}; column = :value, output=:value) where T <: Any
    table(data, set_element[1] => [set_element[2]], column = column, output = output)
end

function table(data::WiNDCtable, set_element::Pair{Symbol, Vector{T}}; column = :value, output=:value) where T <: Any
    d = domain(data, set_element[1])
    e = set_element[2]

    E = elements(data, set_element[1])[!, :name]
    all(x -> x in E, e) || error("Elements $e not found in set $(set_element[1])")

    table(data, d, e; column = column, output = output)
end

function table(data, set_names...; column = :value, output = :value)
    out = Dict()
    for set_name in set_names
        d = domain(data, set_name)
        if !haskey(out, d)
            out[d] = DataFrame()
        end
        X = table(data, set_name; column = column, output = output)
        out[d] = vcat(out[d], X)
    end
    if length(out) == 1
        X = first(values(out))
    else
        X = innerjoin(
                values(out)...,
                on = [domain(data); [:parameter, output]]
            )
    end
    return X
end






"""
    sets(data::WiNDCtable)
    sets(data::WiNDCtable, set_name::Symbol)

Return the sets of a WiNDCtable object. If `set_name` is specified, return only the set
with that name.

!!! note
    `sets(data::WiNDCtable)` must be implemented for any subtype of WiNDCtable.
"""
sets(data::WiNDCtable) = data.sets
function sets(data::WiNDCtable, set_name::Symbol...) 
    out = subset(sets(data), :name => ByRow(∈(set_name)))
    if isempty(out)
        error("Set `$set_name` not found in sets.")
    end
    return out
end

"""
    elements(data::WiNDCtable)
    elements(data::WiNDCtable, set_name::Symbol)

Return the elements of a WiNDCtable object. If `set_name` is specified, return only the elements
belonging to that set.

!!! note
    `elements(data::WiNDCtable)` must be implemented for any subtype of WiNDCtable.
"""
elements(data::WiNDCtable) = data.elements
function elements(data::WiNDCtable, set_name::Symbol...; columns = [:name, :description, :set], parameter::Bool=true) 
    X = subset(elements(data), :set => ByRow(∈(set_name))) #|> x -> select(x, columns)
    if parameter
        Y = subset(X, :parameter => ByRow(y->y))
    else
        Y = subset(X, :parameter => ByRow(y->!y))
    end
    X = !isempty(Y) ? Y : X
    return select(X, columns)
end