@testitem "Getters - Retrieval" begin
    using DataFrames

    struct National <: WiNDCtable
        data::DataFrame
        sets::DataFrame
        elements::DataFrame
    end


    WiNDCContainer.domain(data::National) = [:row, :col]
    WiNDCContainer.base_table(data::National) = data.data
    WiNDCContainer.sets(data::National) = data.sets
    WiNDCContainer.elements(data::National) = data.elements

    param = DataFrame(row = [:a, :b, :va], col = [:s1, :s2, :s1], parameter = [:p1, :p2, :p1], value = [1.0, 2.0, 3.0])
    S = DataFrame(name = [:commodity, :value_added, :sector, :P1, :P2, :P3], description = ["Commodity", "Value Added", "Sector","","",""], domain = [:row, :row, :col, :parameter, :parameter, :parameter])

    E = DataFrame(name = [:a, :b, :va, :s1, :s2, :p1, :p2, :p1, :p2], description = ["", "", "", "", "", "", "", "", ""], set = [:commodity, :commodity, :value_added, :sector, :sector, :P1, :P2, :P3, :P3])
    
    X = National(param, S, E; regularity_check = true)

    @test table(X) == param
    @test table(X, :P1) == param[param.parameter .== :p1, :]
    @test table(X, :P3) == param
    @test table(X, :commodity) == param[param.row .∈ Ref([:a, :b]), :]
    @test table(X, :commodity, :sector) == param[param.row .∈ Ref([:a, :b]) .&& param.col .∈ Ref([:s1, :s2]), :]
    @test table(X, :commodity => :a) == param[param.row .== :a, :]
    @test table(X, :commodity => :a, :sector => :s2) == DataFrame(row=Symbol[], col=Symbol[], parameter=Symbol[], value=Float64[])


    # Order on a leftjoin is not preserved. This sorts so that we get a predictable order to test
    @test table(X; normalize=:P2) |> x->sort(x,:row) == DataFrame(row = [:a, :b, :va], col = [:s1, :s2, :s1], parameter = [:p1, :p2, :p1], value = [1.0, -2.0, 3.0])
    @test table(X; normalize=:P3) |> x->sort(x,:row) == DataFrame(row = [:a, :b, :va], col = [:s1, :s2, :s1], parameter = [:p1, :p2, :p1], value = [-1.0, -2.0, -3.0])
    @test table(X; normalize=[:P1,:P2]) |> x->sort(x,:row) == DataFrame(row = [:a, :b, :va], col = [:s1, :s2, :s1], parameter = [:p1, :p2, :p1], value = [-1.0, -2.0, -3.0])




    @test sets(X) == S
    @test sets(X, :commodity) == S[S.name .== :commodity, :]


    @test elements(X) == E
    @test elements(X, :commodity) == E[E.set .== :commodity, :]


    #@test elements(X, :p3)
end