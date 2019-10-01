using RecipesBase, Unitful, Measurements

@recipe function f(spec::Spectrum)
    seriestype --> :step
    xlabel --> "wave (angstrom)"
    ylabel --> "flux density"
    label --> ""
    spec.wave, Measurements.value.(spec.flux)
end

@recipe function f(spec::UnitfulSpectrum)
    seriestype --> :step
    wunit, funit = unit(spec)
    xlabel --> "wave ($wunit)"
    ylabel --> "flux density ($funit)"
    label --> ""
    ustrip.(spec.wave), Measurements.value.(ustrip.(spec.flux))
end
