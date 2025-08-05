@testitem "Getters - Retrieval" begin
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

    param = DataFrame(row = [:a, :b, :va], col = [:s1, :s2, :s1], parameter = [:p1, :p2, :p1], value = [1.0, 2.0, 3.0])
    S = DataFrame(name = [:commodity, :value_added, :sector, :p1, :p2, :p3], description = ["Commodity", "Value Added", "Sector","","",""], domain = [:row, :row, :col, :parameter, :parameter, :parameter])
    E = DataFrame(name = [:a, :b, :va, :s1, :s2, :p1, :p2, :p1, :p2], description = ["", "", "", "", "", "", "", "", ""], set = [:commodity, :commodity, :value_added, :sector, :sector, :p1, :p2, :p3, :p3], parameter = [false, false, false, false, false, true, true, true, true])
    
    X = National(param, S, E; regularity_check = true)

    @test table(X) == param
    @test table(X, :p1) == param[param.parameter .== :p1, :]
    @test table(X, :p3) == param
    @test table(X, :commodity) == param[param.row .∈ Ref([:a, :b]), :]
    @test table(X, :commodity, :sector) == param[param.row .∈ Ref([:a, :b]) .&& param.col .∈ Ref([:s1, :s2]), :]
    @test table(X, :commodity => :a) == param[param.row .== :a, :]
    @test table(X, :commodity => :a, :sector => :s2) == DataFrame(row=Symbol[], col=Symbol[], parameter=Symbol[], value=Float64[])


    @test sets(X) == S
    @test sets(X, :commodity) == S[S.name .== :commodity, :]


    @test elements(X) == E
    @test elements(X, :commodity) == E[E.set .== :commodity, [:name, :description, :set]]
end