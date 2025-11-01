module DataInterpolationsExt
    using Spectra: Spectra, Spectrum, spectrum
    using DataInterpolations: AbstractInterpolation

    function Spectra.resample(spec::Spectrum, wave_sampled, interp::AbstractInterpolation)
        p = sortperm(spec.wave) # x-scale must be monitonically increasing
        flux_sampled = interp(wave_sampled)
        return spectrum(wave_sampled, flux_sampled; meta = spec.meta)
    end

end # module
