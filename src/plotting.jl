@recipe function f(spec::SingleSpectrum)
    seriestype --> :step
    xlabel --> "wave"
    ylabel --> "flux density"
    label --> ""
    ustrip.(spec.wave), Measurements.value.(ustrip.(spec.flux))
end

@recipe function f(spec::EchelleSpectrum)
    seriestype --> :step
    xlabel --> "wave"
    ylabel --> "flux density"
    label --> ["Order $i" for i in 1:size(spec, 1)]
    spec.wave', spec.flux'
end
