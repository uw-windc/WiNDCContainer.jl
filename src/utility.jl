Base.copy(X::T) where T <: WiNDCtable = T(
    deepcopy(table(X)),
    deepcopy(sets(X)),
    deepcopy(elements(X));
    regularity_check = false

)


"""
    save_table(
        output_path::String
        MU::T;
        overwrite::Bool = false
    ) where T<:WiNDCtable

Save a `WiNDCtable` to a file. The file format is HDF5, which can be opened
in any other language. The file will have the following structure:

year - DataFrame - The data for each year in the `WiNDCtable`
sets - DataFrame - The sets of the `WiNDCtable`
columns - Array - The column names of each yearly DataFrame

## Required Arguments

- `output_path::String`: The path to save the file. Must end in .jld2.
- `MU::WiNDCtable`: The `WiNDCtable` to save.

## Optional Arguments

- `overwrite::Bool`: If true, overwrite the file if it already exists. Default is false.

"""
function save_table(
    output_path::String,
    MU::T;
    overwrite::Bool = false,

) where T <: WiNDCtable

    _, extension = splitext(output_path)

    extension == ".jld2" || error("The output path must end in .jld2.")
    output_path = !isabspath(output_path) ? joinpath(pwd(), output_path) : output_path

    if overwrite
        file = jldopen(output_path, "w+")
    else
        file = jldopen(output_path, "a") # what if file doesn't exist?
    end

    if haskey(file, "type")
        file["type"] == T || error("The type of the table does not match the type of the file.")
    else
        file["type"] = T
    end

    if !haskey(file, "sets")
        file["sets"] = sets(MU)
    end

    if !haskey(file, "elements")
        file["elements"] = elements(MU)
    end

    if !haskey(file, "data")
        file["data"] = table(MU)
    end

    return 

end


"""
    load_table(
        file_path::String
    )

Load a `WiNDCtable` from a file. 

## Required Arguments

- `file_path::String`: The path to the file.
- `years::Int...`: The years to load. If no years are provided, all years in the file
    will be loaded.

## Returns

A subtype of a WiNDCtable, with the data and sets loaded from the file.
"""
function load_table(
    file_path::String,
    #years::Int...
    )

    file_path = !isabspath(file_path) ? joinpath(pwd(), file_path) : file_path
    @assert isfile(file_path) "The file `$file_path` does not exist."

    f = jldopen(file_path, "r+")

    haskey(f, "sets") || error("The file `$file_path` does not have the key `sets`.")
    sets = f["sets"]

    haskey(f, "elements") || error("The file `$file_path` does not have the key `elements`.")
    elements = f["elements"]

    haskey(f, "type") || error("The file `$file_path` does not have the key `type`.")
    T = f["type"]

    haskey(f, "data") || error("The file `$file_path` does not have the key `data`.")
    data = f["data"]

    return T(data, sets, elements)
end



