module WiNDCContainer

    using DataFrames, JuMP, Ipopt, JLD2

    include("structs.jl")

    export WiNDCtable, table, sets, domain, elements, base_table

    include("utility.jl")

    export copy, save_table, load_table

    include("calibration.jl")

    export calibrate, calibrate_fix_variables, calibrate_constraints

    include("aggregate.jl")

    export aggregate

end # module WiNDCContainer
