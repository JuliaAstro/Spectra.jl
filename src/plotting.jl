using RecipesBase, Unitful, Measurements

@recipe function f(spec::Spectrum)
    seriestype --> :path
    yscale --> :log
    xlabel --> "wave (angstrom)"
    ylabel --> "flux density"
    label --> ""
    spec.wave, Measurements.value.(spec.flux)
end

@recipe function f(spec::UnitfulSpectrum)
    seriestype --> :path
    yscale --> :log
    wunit, funit = unit(spec)
    xlabel --> "wave ($wunit)"
    ylabel --> "flux density ($funit)"
    label --> ""
    spec.wave, Measurements.value.(spec.flux)
end
