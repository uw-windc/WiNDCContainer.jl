@testitem "Regularity - Error Checking" begin
    using DataFrames


    struct National <: WiNDCtable
        data::DataFrame
        sets::DataFrame
        elements::DataFrame
    end


    WiNDCContainer.domain(data::National) = [:row, :col, :year]
    WiNDCContainer.table(data::National) = data.data
    WiNDCContainer.sets(data::National) = data.sets
    WiNDCContainer.elements(data::National) = data.elements

    param = DataFrame(row = [], col = [], year = [], parameter = [], value = [])
    S = DataFrame(name = [], description = [], domain = [])
    E = DataFrame(name = [], description = [], set = [])

    @test_throws(
        "Data names do not match expected names: Symbol[] != [:row, :col, :year, :parameter, :value]",
         National(DataFrame(), DataFrame(), DataFrame(); regularity_check = true) 
    )
    @test_throws(
        "Sets DataFrame names do not match expected names: Symbol[] != [:name, :description, :domain]",
        National(param, DataFrame(), DataFrame(); regularity_check = true)
    )
    @test_throws(
        "Elements DataFrame names do not match expected names: Symbol[] != [:name, :description, :set]",
        National(param, S, DataFrame(); regularity_check = true)
    )


    S = DataFrame(name = [:commodity, :value_added, :sector], description = ["Commodity", "Value Added", "Sector"], domain = [:rows, :row, :col])
    @test_throws(
        "Found domain(s) in sets that is not in the domain: [:rows]",
        National(param, S, E; regularity_check = true)
    )

    S = DataFrame(name = [:commodity, :value_added, :sector], description = ["Commodity", "Value Added", "Sector"], domain = [:row, :row, :col])
    E = DataFrame(name = ["com_1", "va_1", "sec_1"], description = ["", "", ""], set = [:commodity, :value_added, :sectors])
    @test_throws(
        "Found set(s) in elements that are not set(s): [:sectors]",
        National(param, S, E; regularity_check = true)
    )


    param = DataFrame(row = [:a, :b], col = [:c, :d], year = [2020, 2021], parameter = [:p1, :p3], value = [1.0, 2.0])
    S = DataFrame(name = [:commodity, :value_added, :sector, :p1, :p2, :year], description = ["Commodity", "Value Added", "Sector", "", "", ""], domain = [:row, :row, :col, :parameter, :parameter, :year])
    E = DataFrame(
        name = [:a, :b, :c, :d, :p1, :p2, 2020, 2021], 
        description = ["", "", "", "", "", "", "", ""], 
        set = [:commodity, :value_added, :sector, :sector, :p1, :p2, :year, :year]
        )
    @test_throws(
        "Found entry in column `parameter` that are not elements: [:p3]",
        National(param, S, E; regularity_check = true)
    )


    param = DataFrame(row = [:a, :b], col = [:c, :e], year = [2020, 2021], parameter = [:p1, :p2], value = [1.0, 2.0])
    S = DataFrame(name = [:commodity, :value_added, :sector, :p1, :p2, :year], description = ["Commodity", "Value Added", "Sector", "", "", ""], domain = [:row, :row, :col, :parameter, :parameter, :year])
    E = DataFrame(
        name = [:a, :b, :c, :d, :p1, :p2, 2020, 2021], 
        description = ["", "", "", "", "", "", "", ""], 
        set = [:commodity, :value_added, :sector, :sector, :p1, :p2, :year, :year]
        )
    @test_throws(
        "Found entry in column `col` that are not elements: [:e]",
        National(param, S, E; regularity_check = true)
    )

end