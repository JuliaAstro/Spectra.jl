using DustExtinction
using Unitful, UnitfulAstro
import Base

export extinct, extinct!, resample, resample!

function Aλ(wave::Number, Av::Real, Rv::Real, law = ccm89)
    if typeof(wave) <: Unitful.Quantity
        # Need to convert to anstrom natively
        wave = ustrip(u"angstrom", wave)
    end
    return Av * law(wave, Rv)
end

function _extinct(spec::Spectrum, Av::Real, Rv::Real = 3.1, law = ccm89)
    factor = @. 10^(-0.4Aλ(spec.wave, Av, Rv, law))
    if eltype(spec.flux) <: Unitful.Quantity
        spec.flux .* factor * Unitful.NoUnits
    else
        spec.flux .* factor
    end
end

"""
    extinct(::Spectrum, Av::Real, Rv::Real=3.1; law=ccm89)

Extinct a spectrum given the total extinction `Av` and the relative attenuation `Rv`. `law` must be a function with signature `law(wave, Rv)`, by default we use `ccm89` from [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) . 

# Examples
```jldoctest
julia> using Spectra

julia> spec = Spectrum(range(1e4, 3e4, length=1000), randn(1000) .+ 100);

julia> extincted_spec = extinct(spec, 0.3);

julia> extinct!(spec, 0.3);

julia> spec.flux ≈ extincted_spec.flux
true

```
"""
function extinct(spec::Spectrum, Av::Real, Rv::Real = 3.1; law = ccm89)
    flux = _extinct(spec, Av, Rv, law)
    Spectrum(spec.wave, flux, spec.sigma, name = spec.name)
end

"""
    extinct!(::Spectrum, Av::Real, Rv::Real=3.1; law=ccm89)

In-place version of `extinct`
"""
function extinct!(spec::Spectrum, Av::Real, Rv::Real = 3.1; law = ccm89)
    spec.flux = _extinct(spec, Av, Rv, law)
end

# Resampling Ops

using Interpolations

function _resample(spec::Spectrum, wavelengths)
    unitlike = false
    if eltype(spec.wave) <: Quantity
        unitlike = true
        w_unit, f_unit = unit(spec)
        spec = ustrip(spec)
        wavelengths = ustrip.(w_unit, wavelengths)
        # Address issue where conversion can lead to floating point errors leading to a BoundsError in the interpolation
        if wavelengths[1] < spec.wave[1] && wavelengths[1] ≈ spec.wave[1]
            wavelengths[1] = spec.wave[1]
        end
        if wavelengths[end] > spec.wave[end] && wavelengths[end] ≈ spec.wave[end]
            wavelengths[end] = spec.wave[end]
        end
    end

    knots = (spec.wave,)
    flux = interpolate(knots, spec.flux, Gridded(Linear())).(wavelengths)
    sigma = interpolate(knots, spec.sigma, Gridded(Linear())).(wavelengths)
    if unitlike
        wavelengths *= w_unit
        flux *= f_unit
        sigma *= f_unit
    end
    return wavelengths, flux, sigma
end


"""
    resample!(::Spectrum, wavelengths)
    resample!(::Spectrum, other::Spectrum)

Resamples a spectrum onto a new wavelength grid- either given explicitly or taken from the wavelengths of another spectrum. The resampling is done using `Interpolations.interpolate` with a `Gridded(Linear())` boundary condition.

!!! warning
    When using Unitful, there can be floating point errors when converting the wavelengths to the units of the given Spectrum's wavelengths. When this happens it is possible to create a `BoundsError` (eg `3.0 μm` → `30000.00000004 Å`). When this happens the wavelength grid is explicitly truncated to the minimum and maximum of the spectrum wavelengths.
"""
function resample(spec::Spectrum, wavelengths) 
    wave, flux, sigma = _resample(spec, wavelengths) 
    Spectrum(wave, flux, sigma, name = spec.name)
end

resample(spec::Spectrum, other::Spectrum) = resample(spec, other.wave)


"""
    resample!(::Spectrum, wavelengths)
    resample!(::Spectrum, other::Spectrum)

In-place version of `resample`
"""
function resample!(spec::Spectrum, wavelengths)
    spec.wave, spec.flux, spec.sigma = _resample(spec, wavelengths)
end

resample!(spec::Spectrum, other::Spectrum) = resample!(spec, other.wave)
