Base.copy(X::T) where T <: WiNDCtable = T(
    deepcopy(table(X)),
    deepcopy(sets(X)),
    deepcopy(elements(X));
    regularity_check = false
)