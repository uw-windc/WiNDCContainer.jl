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
        elements::DataFrame, 
        parameters::DataFrame;
        regularity_check::Bool = true
    ) where T <: WiNDCtable
    
    X = T(data, sets, elements, parameters)

    if regularity_check
        regularity(X)
    end
    return X
end


function regularity(X::T) where T <: WiNDCtable
    # Extract fields and ensure function implemented
    data = table(X)
    SETS = sets(X)
    ELEMENTS = elements(X)
    PARAMS = parameters(X)

    # Ensure all dataframes have the correct columns
    Symbol.(names(data)) == [domain(X); [:parameter, :value]] || error("Data names do not match expected names: $(Symbol.(names(data))) != $([domain(X); [:parameter, :value]])")
    Symbol.(names(SETS)) == [:name, :description, :domain] || error("Sets DataFrame names do not match expected names: $(Symbol.(names(SETS))) != [:name, :description, :domain]")
    Symbol.(names(ELEMENTS)) == [:name, :description, :set] || error("Elements DataFrame names do not match expected names: $(Symbol.(names(ELEMENTS))) != [:name, :description, :set]")
    Symbol.(names(PARAMS)) == [:name, :subtable] || error("Parameters DataFrame names do not match expected names: $(Symbol.(names(PARAMS))) != [:name, :subtable]")

    all(x∈domain(X) for x in unique(SETS[!, :domain])) || error("Found domain(s) in sets that is not in the domain: $([x for x in unique(SETS[!, :domain]) if !(x in domain(X))])")
    set_names = SETS[!, :name]
    all(x∈set_names for x in unique(ELEMENTS[!, :set])) || error("Found set(s) in elements that are not set(s): $([x for x in unique(ELEMENTS[!, :set]) if !(x in set_names)])")

    param_names = PARAMS[!, :name]
    all(x∈param_names for x in unique(data[!, :parameter])) || error("Found parameter(s) in data that are not parameters: $([x for x in unique(data[!, :parameter]) if !(x in param_names)])")
end


"""
    domain(data::T) where T<:WiNDCtable

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


"""
    parameters(data::WiNDCtable)
    parameters(data::WiNDCtable, params::Vector{Symbol}; columns = [:name, :subtable])
    parameters(data::WiNDCtable, param::Symbol; columns = [:name, :subtable])

Return the parameters of a WiNDCtable object. If `param` or `params` is specified
return only the parameters matching those values.

!!! note
    `parameters(data::WiNDCtable)` must be implemented for any subtype of WiNDCtable.
"""
parameters(data::WiNDCtable) = throw(ArgumentError("parameters not implemented for WiNDCtable"))
function parameters(data::WiNDCtable, params::Vector{Symbol}; columns = [:name, :subtable])
    return subset(parameters(data), :name => ByRow(in(params))) |> x -> select(x, columns)
end
parameters(data::WiNDCtable, param::Symbol; columns = [:name, :subtable]) = parameters(data, [param]; columns = columns)


"""
    table(data::WiNDCtable)
    table(data::WiNDCtable, params::Vector{Symbol})
    table(data::WiNDCtable, parameter::Symbol)

Return the main table of a WiNDCtable object. If `params` or `parameter` is specified,
return only the rows of the table that match the specified parameters.

!!! note
    `table(data::WiNDCtable)` must be implemented for any subtype of WiNDCtable.
"""
table(data::WiNDCtable) = data.data
function table(data::WiNDCtable, params::Vector{Symbol})
    innerjoin(
        table(data),
        parameters(data, params; columns = [:subtable]),
        on = :parameter => :subtable
    )
end
function table(data::WiNDCtable, parameter::Symbol) 
    return table(data, [parameter])
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
function sets(data::WiNDCtable, set_name::Symbol) 
    out = subset(sets(data), :name => ByRow(==(set_name)))
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
function elements(data::WiNDCtable, set_name::Symbol; columns = [:name, :description, :set]) 
    subset(elements(data), :set => ByRow(==(set_name))) |> x -> select(x, columns)
end