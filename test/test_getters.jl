@testitem "Getters - Retrieval" begin
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

    param = DataFrame(row = [:a, :b], col = [:c, :d], year = [2020, 2021], parameter = [:p1, :p2], value = [1.0, 2.0])
    S = DataFrame(name = [:commodity, :value_added, :sector], description = ["Commodity", "Value Added", "Sector"], domain = [:row, :row, :col])
    E = DataFrame(name = ["com_1", "com_2", "va_1", "sec_1"], description = ["", "", "", ""], set = [:commodity, :commodity, :value_added, :sector])
    P = DataFrame(name = [:p1, :p2, :p3, :p3], subtable = [:p1, :p2, :p1, :p2])
    
        
    X = National(param, S, E, P; regularity_check = true)

    @test table(X) == param
    @test sets(X) == S
    @test elements(X) == E
    @test parameters(X) == P

    @test table(X, :p1) == param[param.parameter .== :p1, :]
    @test table(X, :p3) == param
    @test table(X, [:p1, :p2]) == param

    @test sets(X, :commodity) == S[S.name .== :commodity, :]

    @test elements(X, :commodity) == E[E.set .== :commodity, :]
    
    @test parameters(X, :p1) == P[P.name .== :p1, :]
    @test parameters(X, :p3) == P[P.name .== :p3, :]


end
        