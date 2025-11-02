module DataInterpolationsExt

using Spectra: Spectra, Spectrum, spectrum, wave, flux
import Spectra: resample
using DataInterpolations: DataInterpolations, AbstractInterpolation

"""
    function Spectra.resample(spec::Spectrum, wave_sampled, interp::AbstractInterpolation)

Resample `spec` using the given interpolator `interp`.

```jldoctest
julia> using Spectra: spectrum, resample, wave, flux

julia> using DataInterpolations

julia> spec = spectrum([2, 4, 12, 16, 20], [1, 3, 7, 6, 20]);

julia> wave_sampled = [1, 5, 9, 13, 14, 17, 21, 22, 23];

julia> interp = LinearInterpolation(flux(spec), wave(spec); extrapolation = ExtrapolationType.Constant);

julia> resample(spec, wave_sampled, interp)
Spectrum(Int64, Float64)

See [resample(spec::Spectrum, wave_sampled, interp::Type{<:DataInterpolations.AbstractInterpolation} ; kws...)](@ref) for a convenience function version.
```
"""
function Spectra.resample(spec::Spectrum, wave_sampled, interp::AbstractInterpolation)
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

For better performance, see [Spectra.resample(spec::Spectrum, wave_sampled, interp::DataInterpolations.AbstractInterpolation)](@ref).
```
"""
function Spectra.resample(spec::Spectrum, wave_sampled, interp::Type{<:AbstractInterpolation}; kws...)
    itp = interp(flux(spec), wave(spec); kws...)
    flux_sampled = itp(wave_sampled)
    return spectrum(wave_sampled, flux_sampled; meta = spec.meta)
end

end # module
