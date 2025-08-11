module WiNDCContainer

    using DataFrames, JuMP, Ipopt

    include("structs.jl")

    export WiNDCtable, table, sets, domain, elements

    include("utility.jl")

    export copy

    include("calibration.jl")

    export calibrate, calibrate_fix_variables, calibrate_constraints

    include("aggregate.jl")

    export aggregate

end # module WiNDCContainer
