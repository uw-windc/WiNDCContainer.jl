"""
    aggregate(X::T, aggregation::DataFrame; regularity_check=false) where T <: WiNDCtable

Aggregate the WiNDCtable `X` using the provided `aggregation` DataFrame. 

## Required Arguments

- `X::T`: The WiNDCtable to be aggregated.
- `aggregation::DataFrame`: A DataFrame specifying the aggregation rules. Must 
    have columns `set`, `element`, and `new`. All entries in the `set` column must be
    sets in `X`, similarly all entries in the `element` column must be elements in `X`.

## Optional Arguments

- `regularity_check::Bool`: If true, perform a regularity check on the aggregated data. Default is false.

"""
function aggregate(X::T, aggregation::DataFrame; regularity_check=false) where T <: WiNDCtable
    Y = copy(X)

    # Ensure dataframe names are correct
    Symbol.(names(aggregation)) == [:set, :element, :new] || error("`aggregation` must have columns `set`, `element`, and `new`")

    # All entries in `aggregation` must correspond to sets/elements in `X`
    num_element_overlap = innerjoin(elements(X), aggregation, on = [:name => :element, :set]) |> x -> size(x, 1)
    num_element_overlap == size(aggregation, 1) || error(
        "There are sets or elements in `aggregation` that are not sets or elements in `X`" 
        )


    aggregation_sets = select(aggregation, :set) |> unique

    # Find the aggregated sets
    ag_sets = innerjoin(
        sets(Y),
        aggregation_sets,
        on = :name => :set
    ) 

    # Replace the old elements with new elements
    for row in eachrow(ag_sets)
        set_name = row.name
        dom = row.domain

        table(Y) |>
            x -> leftjoin!(
                x,
                subset(aggregation, :set => ByRow(==(set_name))) |> x -> select(x, Not(:set)),
                on = dom => :element
            ) |>
            x -> transform!(x,
                [:new, dom] => ByRow(coalesce) => dom
            ) |>
            x -> select!(x, Not(:new)) 

    end

    # Aggregate
    new_data = table(Y) |>
        x -> groupby(x, [domain(Y);[:parameter]]) |>
        x -> combine(x, :value => sum => :value) 

    # Update the elements table
    elements(Y) |>
        x -> leftjoin!(
            x,
            aggregation,
            on = [:name => :element, :set],
        ) |>
        x -> transform!(x,
            [:new, :name] => ByRow(coalesce) => :name
        ) |>
        x -> select!(x, Not(:new)) |>
        x -> unique!(x, [:name, :set])

    return T(new_data, sets(Y), elements(Y); regularity_check = regularity_check)
end