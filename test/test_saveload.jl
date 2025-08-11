@testitem "Regularity - Error Checking" begin
    using DataFrames


    struct National <: WiNDCtable
        data::DataFrame
        sets::DataFrame
        elements::DataFrame
    end


    WiNDCContainer.domain(data::National) = [:row, :col]
    WiNDCContainer.table(data::National) = data.data
    WiNDCContainer.sets(data::National) = data.sets
    WiNDCContainer.elements(data::National) = data.elements

    function generate_random_data(parameter_name::Symbol, row_set, col_set; output = false)
        out = []
        sign = output ? -1 : 1
        for r in row_set, c in col_set
            push!(out, (row = r, col = c, parameter = parameter_name, value = sign * 10 * rand()))
        end
        return out
    end


    SETS = DataFrame([
        (name = :commodity, description = "", domain = :row),
        (name = :sector, description = "", domain = :col),
        (name = :value_added, description = "", domain = :row),
        (name = :final_demand, description = "", domain = :col),
        (name = :IntermediateDemand, description = "", domain = :parameter),
        (name = :ValueAdded, description = "", domain = :parameter),
    ])


    ELEMENTS = DataFrame([
        (name = :com1, description = "", set = :commodity),
        (name = :com2, description = "", set = :commodity),
        (name = :sec1, description = "", set = :sector),
        (name = :sec2, description = "", set = :sector),
        (name = :va1, description = "", set = :value_added),
        (name = :va2, description = "", set = :value_added),
        (name = :intermediate_demand, description = "", set = :IntermediateDemand),
        (name = :value_added, description = "", set = :ValueAdded),
    ])

    DATA = DataFrame([
        (row = :com1, col = :sec1, parameter = :intermediate_demand, value = 1.0),
        (row = :com1, col = :sec2, parameter = :intermediate_demand, value = 1.0),
        (row = :com2, col = :sec1, parameter = :intermediate_demand, value = 1.0),
        (row = :com2, col = :sec2, parameter = :intermediate_demand, value = 1.0),
        (row = :va1, col = :sec1, parameter = :value_added, value = 1.0),
        (row = :va1, col = :sec2, parameter = :value_added, value = 1.0),
        (row = :va2, col = :sec1, parameter = :value_added, value = 1.0),
        (row = :va2, col = :sec2, parameter = :value_added, value = 1.0),
    ])


    X = National(
        DATA,
        SETS,
        ELEMENTS;
        regularity_check = true
    )


    save_table("test.jld2", X)
    Y = load_table("test.jld2")

    @test table(Y) == table(X)
    @test sets(Y) == sets(X)
    @test elements(Y) == elements(X)

end