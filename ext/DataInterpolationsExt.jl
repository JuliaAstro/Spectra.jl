module DataInterpolationsExt

using Spectra: Spectra, Spectrum, spectrum, wave, flux
import Spectra: resample
using DataInterpolations: AbstractInterpolation

function Spectra.resample(spec::Spectrum, wave_sampled, interp::AbstractInterpolation)
    # p = sortperm(spec.wave) # x-scale must be monitonically increasing; not being used
    flux_sampled = interp(wave_sampled)
    return spectrum(wave_sampled, flux_sampled; meta = spec.meta)
end

"""
    resample(spec::Spectrum, wave_sampled, interp::Type{<:DataInterpolations.AbstractInterpolation}; kws...)
Constructs an interpolator of type `interp` from the provided spectrum `spec` and evaluates it at `wave_sampled`, returning a `Spectrum`. The `kws...` control extrapolation and are passed through to the interpolator.

```jldoctest
julia> using Spectra, DataInterpolations

julia> spec = spectrum([2, 4, 12, 16, 20], [1, 3, 7, 6, 20]);

julia> wave_sampled = [1, 5, 9, 13, 14, 17, 21, 22, 23];

julia> resample(spec, wave_sampled, LinearInterpolation; extrapolation = ExtrapolationType.Constant)
Spectrum(Int64, Float64)
```
"""
function Spectra.resample(spec::Spectrum, wave_sampled, interp::Type{<:AbstractInterpolation}; kws...)
    # Not sure if we have to check wave is monotonically increasing or if that is guaranteed by the constructor?
    p = sortperm(wave(spec))
    itp = interp(flux(spec)[p], wave(spec)[p]; kws...)
    flux_sampled = itp.(wave_sampled)
    return spectrum(wave_sampled, flux_sampled; meta = spec.meta)
end

end # module
