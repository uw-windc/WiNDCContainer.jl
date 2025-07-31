# WiNDC Containers

This package provides a set of tools for working with structured economic data. It provides functionality to 

- Manipulate and explore IO tables
- Generic methods to calibrate the data

This package is a work in progress. For an example of a use case see the [WiNDCNational.jl](https://github.com/uw-windc/WiNDCNational.jl) package. 

## Future Work

- Documentation
- Methods to aggregate/disaggregate data
-

## Small Example

The primary base type is `WiNDCtable` which you must sub-type with a concrete type. For example, to create a new table type for national data, you can define a struct like this:

```julia
using WiNDCContainer
using DataFrames

import WiNDCContainer: WiNDCtable, table, sets, parameters, domain, elements
import WiNDCContainer: calibrate, calibrate_fix_variables, calibrate_constraints

struct National <: WiNDCtable
    data::DataFrame
    sets::DataFrame
    elements::DataFrame
    parameters::DataFrame
end
```

Note that the order of the fields is important. The columns of the DataFrames are also important, they will be defined below.

Next you must overwrite five methods:

```julia
domain(data::National) = [:row, :col, :year]
parameters(data::National) = data.parameters
table(data::National) = data.data
sets(data::National) = data.sets
elements(data::National) = data.elements
```

These are the `getter` methods for the `National` table type. These are used with `WiNDCContainer` to extract and manipulate the data.

With this let's discuss the structure of the DataFrames. 

1. `data` should have `N+2` columns. The first `N` are defined by `domain`, the last two are `parameter` and `value`. 
2. `sets` should have `3` columns: `name`, `description`, and `domain`. The `domain` column should be a vector of symbols that match the `domain` method.
3. `elements` also has `3` columns: `name`, `description`, and `set`. All values in the `set` column must appear in the `name` column of `sets`.
4. `parameters` should have `2` columns: `name` and `subtable`. The `name` column is the name of the parameter. The `subtable` column links the parameter name to the `parameter` column in `data`. To be clear, the `subtable` column should contain the same values as the `parameter` column in `data`.

These are a lot of conditions that are easy to get wrong. To help with this, we provide a constructor with the keyword `regularity_check` that checks these conditions when creating a new table.

For example:

```julia
param = DataFrame(
    row = [:a, :b], 
    col = [:c, :d], 
    year = [2020, 2021], 
    parameter = [:p1, :p3], 
    value = [1.0, 2.0]
    )
S = DataFrame(
    name = [:commodity, :value_added, :sector], 
    description = ["Commodity", "Value Added", "Sector"], 
    domain = [:row, :row, :col]
)
E = DataFrame(
    name = ["com_1", "va_1", "sec_1"], 
    description = ["", "", ""], 
    set = [:commodity, :value_added, :sector]
)
P = DataFrame(
    name = [:p1, :p2], 
    subtable = [:p1, :p2]
)


N_bad = National(
    param,  # data
    S,      # sets
    E,      # elements
    P       # parameters
)

N = National(
    param, 
    S, 
    E, 
    P; 
    regularity_check = true
)
```
The first `National` constructor will not throw an error since no checks are performed. However, the second one will throw an error as we checking for regularity as in `param` we have a parameter `p3` that does not exist in `P`.


Let's define a small example of how to use this `National` table type:

```julia
param = DataFrame(
    row = [:a, :b], 
    col = [:c, :d], 
    year = [2020, 2021], 
    parameter = [:p1, :p2], 
    value = [1.0, 2.0]
    )
S = DataFrame(
    name = [:commodity, :value_added, :sector], 
    description = ["Commodity", "Value Added", "Sector"], 
    domain = [:row, :row, :col]
)
E = DataFrame(
    name = ["com_1", "va_1", "sec_1"], 
    description = ["", "", ""], 
    set = [:commodity, :value_added, :sector]
)
P = DataFrame(
    name = [:p1, :p2, :p3, :p3], 
    subtable = [:p1, :p2, :p1, :p2]
)

N = National(
    param, 
    S, 
    E, 
    P; 
    regularity_check = true
)
```

Notice that `P` has a parameter `p3` that is linked to the `subtable`s `p1` and `p2`. This will let us extract both `p1` and `p2` from the `data` DataFrame. The following two commands produce the same result:

```julia
table(N, :p3)

table(N, [:p1, :p2])
```

Defining `p3` in the `parameters` DataFrame provides a short hand for extracting different parameters.

Similarly, if we want to view all the commodities:

```julia
elements(N, :commodity)
```

This example only has one commodity element, but it will return a DataFrame with all the elements in the commodity set.