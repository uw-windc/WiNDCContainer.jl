@testitem "Aggregation - Error Checking" begin
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


    SETS = DataFrame(
        name = [:commodity, :sector, :value_added, :final_demand, :import, :export, :IntermediateDemand, :IntermediateSupply, :ValueAdded, :FinalDemand, :Import, :Export, :ExFinalDemand],
        description = ["", "" , "", "", "", "", "", "", "", "", "", "", ""],
        domain = [:row, :col, :row, :col, :col, :col, :parameter, :parameter, :parameter, :parameter, :parameter, :parameter, :parameter],
    )

    n_com = 10
    n_sec = 10
    n_va = 3
    n_fd = 3
    commodities = Symbol.("com",1:n_com);
    sectors = Symbol.("sec",1:n_sec);
    value_added = Symbol.("va",1:n_va);
    final_demand = Symbol.("fd",1:n_fd);


    ELEMENTS = DataFrame(
        name = [
            commodities;
            sectors;
            value_added;
            final_demand;
            [:import, :export];
            [:intermediate_demand, :intermediate_supply, :ValueAdded, :ExFinalDemand, :Export, :Import, :Export, :ExFinalDemand]
        ],
        description = [
            ["" for _ in 1:n_com];
            ["" for _ in 1:n_sec];
            ["" for _ in 1:n_va];
            ["" for _ in 1:n_fd];
            ["", ""];
            ["" for _ in 1:8]
        ],
        set = [
            [:commodity for _ in 1:n_com];
            [:sector for _ in 1:n_sec];
            [:value_added for _ in 1:n_va];
            [:final_demand for _ in 1:n_fd];
            [:import, :export];
            [:IntermediateDemand, :IntermediateSupply, :ValueAdded, :FinalDemand, :FinalDemand, :Import, :Export, :ExFinalDemand]
        ]
    )

    DATA = DataFrame(
        [
            generate_random_data(:intermediate_demand, commodities, sectors);
            generate_random_data(:intermediate_supply, commodities, sectors; output = true);
            generate_random_data(:ValueAdded, value_added, sectors);
            generate_random_data(:ExFinalDemand, commodities, final_demand);
            generate_random_data(:Import, commodities, [:import], output = true);
            generate_random_data(:Export, commodities, [:export]);
        ]
    )

    X = National(
        DATA,
        SETS,
        ELEMENTS;
        regularity_check = true
    )


    aggregation = DataFrame(
        [
            (set = :commodity, element = :com1,  new = :c),
            (set = :commodity, element = :com2,  new = :c),
            (set = :commodity, element = :com3,  new = :c),
            (set = :commodity, element = :com4,  new = :c),
            (set = :commodity, element = :com5,  new = :c),
            (set = :commodity, element = :com6,  new = :c),
            (set = :commodity, element = :com7,  new = :c),
            (set = :commodity, element = :com8,  new = :c),
            (set = :commodity, element = :com9,  new = :c),
            (set = :commodity, element = :com10, new = :c),
            (set = :sector,    element = :sec1,  new = :s),
            (set = :sector,    element = :sec2,  new = :s),
            (set = :sector,    element = :sec3,  new = :s),
            (set = :value_adde, element = :va1, new = :v),
            (set = :value_added, element = :va2, new = :v),
        ]
    )

    @test_throws(
        "There are sets or elements in `aggregation` that are not sets or elements in `X`",
         aggregate(X, aggregation)
    )


    aggregation = DataFrame(
        [
            (sets = :commodity, element = :com1,  new = :c),
        ]
    )

    @test_throws(
        "`aggregation` must have columns `set`, `element`, and `new`",
         aggregate(X, aggregation)
    )

end




@testitem "Aggregation - Output" begin
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

    aggregation = DataFrame(
        [
            (set = :commodity, element = :com1,  new = :c),
            (set = :commodity, element = :com2,  new = :c),
            (set = :sector,    element = :sec1,  new = :s),
            (set = :sector,    element = :sec2,  new = :s),
            (set = :value_added, element = :va1, new = :v),
            (set = :value_added, element = :va2, new = :v),
        ]
    )


    X = National(
        DATA,
        SETS,
        ELEMENTS;
        regularity_check = true
    )

    Y = aggregate(X, aggregation)
    
    expected = DataFrame([
        (row = :c, col = :s, parameter = :intermediate_demand, value = 4.0),
        (row = :v, col = :s, parameter = :value_added, value = 4.0),
    ])

    @test table(Y) == expected

    ELEMENTS = DataFrame([
        (name = :c, description = "", set = :commodity),
        (name = :s, description = "", set = :sector),
        (name = :v, description = "", set = :value_added),
        (name = :intermediate_demand, description = "", set = :IntermediateDemand),
        (name = :value_added, description = "", set = :ValueAdded),
    ])

    @test elements(Y) == ELEMENTS



end