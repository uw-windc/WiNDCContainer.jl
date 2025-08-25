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
end
```

Note that the order of the fields is important. The columns of the DataFrames are also important, they will be defined below.

Next you must overwrite five methods:

```julia
domain(data::National) = [:row, :col, :year]
base_table(data::National) = data.data
sets(data::National) = data.sets
elements(data::National) = data.elements
```

These are the `getter` methods for the `National` table type. These are used with `WiNDCContainer` to extract and manipulate the data.

With this let's discuss the structure of the DataFrames. 

1. `data` should have `N+2` columns. The first `N` are defined by `domain`, the last two are `parameter` and `value`. 
2. `sets` should have `3` columns: `name`, `description`, and `domain`. The `domain` column should be a vector of symbols that match the `domain` method.
3. `elements` also has `3` columns: `name`, `description`, and `set`. All values in the `set` column must appear in the `name` column of `sets`.

These are a lot of conditions that are easy to get wrong. To help with this, we provide a constructor with the keyword `regularity_check` that checks these conditions when creating a new table.

For example:

```julia
DATA = DataFrame([
    (row = :a, col = :c, year = 2020, parameter = :p1, value = 1.0),
    (row = :b, col = :d, year = 2021, parameter = :p3, value = 2.0)
])

S = DataFrame([
    (name = :commodity,   description = "Commodity",    domain = :row),
    (name = :value_added, description = "Value Added",  domain = :row),
    (name = :sector,      description = "Sector",       domain = :col),
    (name = :year,        description = "Year",         domain = :year),
    (name = :P1,          description = "Parameter",    domain = :parameter),
    (name = :P2,          description = "Parameter",    domain = :parameter)
])

E = DataFrame([
    (name = :a,   description = "", set = :commodity),
    (name = :b,   description = "", set = :value_added),
    (name = :c,   description = "", set = :sector),
    (name = :d,   description = "", set = :sector),
    (name = 2020, description = "", set = :year),
    (name = 2021, description = "", set = :year),
    (name = :p1,  description = "", set = :P1),
    (name = :p2,  description = "", set = :P2)
])


N_bad = National(
    DATA,  # data
    S,      # sets`
    E,      # elements
)

N = National(
    DATA, 
    S, 
    E, 
    regularity_check = true
)
```
The first `National` constructor will not throw an error since no checks are performed. However, the second one will throw an error as we checking for regularity as in `DATA` we have a parameter `p3` that does not exist in as an element.


Let's define a small working example:

```julia
DATA = DataFrame([
    (row = :a, col = :c, year = 2020, parameter = :p1, value = 1.0),
    (row = :b, col = :d, year = 2021, parameter = :p2, value = 2.0)
])

S = DataFrame([
    (name = :commodity,   description = "Commodity",    domain = :row),
    (name = :value_added, description = "Value Added",  domain = :row),
    (name = :sector,      description = "Sector",       domain = :col),
    (name = :year,        description = "Year",         domain = :year),
    (name = :P1,          description = "Parameter",    domain = :parameter),
    (name = :P2,          description = "Parameter",    domain = :parameter),
    (name = :P3,          description = "Parameter",    domain = :parameter)
])

E = DataFrame([
    (name = :a,   description = "", set = :commodity),
    (name = :b,   description = "", set = :value_added),
    (name = :c,   description = "", set = :sector),
    (name = :d,   description = "", set = :sector),
    (name = 2020, description = "", set = :year),
    (name = 2021, description = "", set = :year),
    (name = :p1,  description = "", set = :P1),
    (name = :p2,  description = "", set = :P2),
    (name = :p1,  description = "", set = :P3),
    (name = :p2,  description = "", set = :P3),
])

N = National(
    DATA, 
    S, 
    E, 
    regularity_check = true
)
```

Notice we added the set `P3` with elements `p1` and `p2`. This will let us extract both `p1` and `p2` from the `data` DataFrame. The following two commands produce the same result:

```julia
table(N, :P3)

table(N, [:P1, :P2])
```

Defining `P3` in the `parameters` DataFrame provides a short hand for extracting different parameters.

If we want to view all the commodities:

```julia
elements(N, :commodity)
```

This example only has one commodity element, but it will return a DataFrame with all the elements in the commodity set.

You can also extract specific elements from the table, for example to get all the data elements where the sector is `c`:

```julia
table(N, :sector => :c)
```