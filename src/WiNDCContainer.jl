module WiNDCContainer

    using DataFrames, JuMP, Ipopt

    include("structs.jl")

    export WiNDCtable, table, sets, parameters, domain, elements

    include("calibration.jl")

    export calibrate, calibrate_fix_variables, calibrate_constraints


end # module WiNDCContainer
