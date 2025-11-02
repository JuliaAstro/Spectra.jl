module InterpolationsExt

using Spectra: Spectra, Spectrum, spectrum, wave, flux
import Spectra: resample
using Interpolations:
    Interpolations,
    AbstractInterpolation,
    Degree,
    Constant,
    Linear,
    Cubic,
    constant_interpolation,
    linear_interpolation,
    cubic_interpolation

"""
    Spectra.resample(spec::Spectrum, wave_sampled, interp::AbstractInterpolation)

Resample `spec` using the given interpolator `interp`.

```jldoctest
julia> using Spectra: spectrum, resample, wave, flux

julia> using Interpolations

julia> spec = spectrum([2, 4, 12, 16, 20], [1, 3, 7, 6, 20]);

julia> wave_sampled = [1, 5, 9, 13, 14, 17, 21, 22, 23];

julia> interp = extrapolate(interpolate((wave(spec), ), flux(spec), Gridded(Linear())), Flat());

julia> resample(spec, wave_sampled, interp)
Spectrum(Int64, Float64)
```

See [resample(spec::Spectrum, wave_sampled, deg::Interpolations.Degree; kws...)](@ref) for a convenience function version with limited flexibility.
"""
function Spectra.resample(spec::Spectrum, wave_sampled, interp::AbstractInterpolation)
    flux_sampled = interp(wave_sampled)
    return spectrum(wave_sampled, flux_sampled; meta = spec.meta)
end

"""
    resample(spec::Spectrum, wave_sampled, deg::Interpolations.Degree; kws...)

Constructs an interpolator of type `interp` from the provided spectrum `spec` and evaluates it at `wave_sampled`, returning a `Spectrum`. The `kws...` control extrapolation and are passed through to the interpolator.

```jldoctest
julia> using Spectra: spectrum, resample

julia> using Interpolations: Flat

julia> spec = spectrum([2, 4, 12, 16, 20], [1, 3, 7, 6, 20]);

julia> wave_sampled = [1, 5, 9, 13, 14, 17, 21, 22, 23];

julia> resample(spec, wave_sampled, Linear(); extrapolation_bc = Flat())
Spectrum(Int64, Float64)
```

This convenience function currently only supports `Constant`, `Linear`, and `Cubic` splines from Interpolations.jl. For more interpolators and better performance, see [Spectra.resample(spec::Spectrum, wave_sampled, interp::Interpolations.AbstractInterpolation)](@ref).
"""
function Spectra.resample(spec::Spectrum, wave_sampled, deg::Degree; kws...)

    deg_func = if deg isa Constant
        constant_interpolation
    elseif deg isa Linear
        linear_interpolation
    elseif deg isa Cubic
        cubic_interpolation
    else
        throw(ArgumentError(deg, "Invalid degree passed. Must be one of `Constant`, `Linear`, `Quadratic`, or `Cubic`."))
    end

    itp = deg_func(wave(spec), flux(spec); kws...)
    flux_sampled = itp(wave_sampled)
    return spectrum(wave_sampled, flux_sampled; meta = spec.meta)
end

end # module
