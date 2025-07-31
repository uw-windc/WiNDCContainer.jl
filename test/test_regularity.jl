@testitem "Regularity - Error Checking" begin
    using DataFrames


    struct National <: WiNDCtable
        data::DataFrame
        sets::DataFrame
        elements::DataFrame
        parameters::DataFrame
    end


    WiNDCContainer.domain(data::National) = [:row, :col, :year]
    WiNDCContainer.parameters(data::National) = data.parameters
    WiNDCContainer.table(data::National) = data.data
    WiNDCContainer.sets(data::National) = data.sets
    WiNDCContainer.elements(data::National) = data.elements

    param = DataFrame(row = [], col = [], year = [], parameter = [], value = [])
    S = DataFrame(name = [], description = [], domain = [])
    E = DataFrame(name = [], description = [], set = [])
    P = DataFrame(name = [], subtable = [])

    @test_throws(
        "Data names do not match expected names: Symbol[] != [:row, :col, :year, :parameter, :value]",
         National(DataFrame(), DataFrame(), DataFrame(), DataFrame(); regularity_check = true) 
    )
    @test_throws(
        "Sets DataFrame names do not match expected names: Symbol[] != [:name, :description, :domain]",
        National(param, DataFrame(), DataFrame(), DataFrame(); regularity_check = true)
    )
    @test_throws(
        "Elements DataFrame names do not match expected names: Symbol[] != [:name, :description, :set]",
        National(param, S, DataFrame(), DataFrame(); regularity_check = true)
    )
    @test_throws(
        "Parameters DataFrame names do not match expected names: Symbol[] != [:name, :subtable]",
        National(param, S, E, DataFrame(); regularity_check = true)
    )


    S = DataFrame(name = [:commodity, :value_added, :sector], description = ["Commodity", "Value Added", "Sector"], domain = [:rows, :row, :col])
    @test_throws(
        "Found domain(s) in sets that is not in the domain: [:rows]",
        National(param, S, E, P; regularity_check = true)
    )

    S = DataFrame(name = [:commodity, :value_added, :sector], description = ["Commodity", "Value Added", "Sector"], domain = [:row, :row, :col])
    E = DataFrame(name = ["com_1", "va_1", "sec_1"], description = ["", "", ""], set = [:commodity, :value_added, :sectors])
    @test_throws(
        "Found set(s) in elements that are not set(s): [:sectors]",
        National(param, S, E, P; regularity_check = true)
    )

    param = DataFrame(row = [:a, :b], col = [:c, :d], year = [2020, 2021], parameter = [:p1, :p3], value = [1.0, 2.0])
    S = DataFrame(name = [:commodity, :value_added, :sector], description = ["Commodity", "Value Added", "Sector"], domain = [:row, :row, :col])
    E = DataFrame(name = ["com_1", "va_1", "sec_1"], description = ["", "", ""], set = [:commodity, :value_added, :sector])
    P = DataFrame(name = [:p1, :p2], subtable = [:p1, :p2])
    @test_throws(
        "Found parameter(s) in data that are not parameters: [:p3]",
        National(param, S, E, P; regularity_check = true)
    )

end