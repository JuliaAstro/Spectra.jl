using DustExtinction
using Unitful, UnitfulAstro
import Base

export extinct, extinct!

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

# See Also
[`extinct`](@ref)
"""
function extinct!(spec::Spectrum, Av::Real, Rv::Real = 3.1; law = ccm89)
    spec.flux = _extinct(spec, Av, Rv, law)
end

# TODO 

function resample(spec::Spectrum, wavelengths)

end

resample(spec::Spectrum, other::Spectrum) = resample(spec, other.wave)

function resample!(spec::Spectrum, wavelengths)

end

resample!(spec::Spectrum, other::Spectrum) = resample!(spec, other.wave)
