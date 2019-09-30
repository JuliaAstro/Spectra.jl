using RecipesBase, Unitful, Measurements

@recipe function f(spec::Spectrum)
    seriestype --> :path
    yscale --> :log
    xlabel --> "wave (angstrom)"
    ylabel --> "flux density"
    label --> ""
    spec.wave, Measurements.value.(spec.flux)
end

# @recipe function f(::Type{Spectrum{W, T}}, spec::Spectrum{W, T}) where {W <: Quantity, T<: Quantity}
#     seriestype --> :path
#     yaxis --> :log
#     xunit, yunit = unit(spec)
#     xlabel --> string(xunit)
#     ylabel --> string(yunit)
#     label --> spec.name
#     x := spec.wave
#     y := Measurements.value.(spec.flux)
# end