@recipe function f(spec::SingleSpectrum)
    seriestype --> :step
    xlabel --> "wave"
    ylabel --> "flux density"
    label --> ""
    ustrip.(spectral_axis(spec)), Measurements.value.(ustrip.(flux_axis(spec)))
end

@recipe function f(spec::EchelleSpectrum)
    seriestype --> :step
    xlabel --> "wave"
    ylabel --> "flux density"
    label --> ["Order $i" for i in 1:size(spec, 1)]
    spectral_axis(spec)', flux_axis(spec)'
end
