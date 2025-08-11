module WiNDCContainer

    using DataFrames, JuMP, Ipopt, JLD2

    include("structs.jl")

    export WiNDCtable, table, sets, domain, elements

    include("utility.jl")

    export copy, save_table, load_table

    include("calibration.jl")

    export calibrate, calibrate_fix_variables, calibrate_constraints


end # module WiNDCContainer
