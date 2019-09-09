using DustExtinction
using Unitful, UnitfulAstro
import Base

export extinct, extinct!, resample, resample!

_extinct(wave::Real, flux::Real, Av, Rv = 3.1, law = ccm89) =  flux * 10^(-0.4*Av * law(wave, Rv))
# Unitful version
_extinct(wave::Quantity, flux::Quantity, Av, Rv=3.1, law = ccm89) = flux * (Av * law(wave, Rv))

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
    flux = _extinct.(spec.wave, spec.flux, Av, Rv, law)
    Spectrum(spec.wave, flux, name = spec.name)
end

"""
    extinct!(::Spectrum, Av::Real, Rv::Real=3.1; law=ccm89)

In-place version of `extinct`
"""
function extinct!(spec::Spectrum, Av::Real, Rv::Real = 3.1; law = ccm89)
    spec.flux .= _extinct.(spec.wave, spec.flux, Av, Rv, law)
    spec
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
    if unitlike
        wavelengths *= w_unit
        flux *= f_unit
    end
    return wavelengths, flux
end


"""
    resample!(::Spectrum, wavelengths)
    resample!(::Spectrum, other::Spectrum)

Resamples a spectrum onto a new wavelength grid- either given explicitly or taken from the wavelengths of another spectrum. The resampling is done using `Interpolations.interpolate` with a `Gridded(Linear())` boundary condition.

!!! warning
    When using Unitful, there can be floating point errors when converting the wavelengths to the units of the given Spectrum's wavelengths. When this happens it is possible to create a `BoundsError` (eg `3.0 μm` → `30000.00000004 Å`). When this happens the wavelength grid is explicitly truncated to the minimum and maximum of the spectrum wavelengths.
"""
function resample(spec::Spectrum, wavelengths) 
    wave, flux = _resample(spec, wavelengths) 
    Spectrum(wave, flux, name = spec.name)
end

resample(spec::Spectrum, other::Spectrum) = resample(spec, other.wave)


"""
    resample!(::Spectrum, wavelengths)
    resample!(::Spectrum, other::Spectrum)

In-place version of `resample`
"""
function resample!(spec::Spectrum, wavelengths)
    spec.wave, spec.flux = _resample(spec, wavelengths)
end

resample!(spec::Spectrum, other::Spectrum) = resample!(spec, other.wave)

## Broadening ops
include("kernels.jl")
using Distributions
using FastConv

function _broaden(flux, sigma, kernel::Kernel)
    k = evaluate(kernel)
    broad_flux = convn(flux, k)
    broad_sigma = convn(sigma, k)
end

function broaden(spec::Spectrum, kernel::Kernel)
    w_unit, f_unit = unit(spec)
    s = ustrip(spec)
    broad_flux, broad_sigma = _broaden(s.flux, s.sigma, kernel)
    return Spectrum(spec.wave, broad_flux*f_unit, broad_sigma*f_unit, name=spec.name)
end
