using DustExtinction
using Unitful, UnitfulAstro
import Base

export extinct, extinct!

DUST_LAWS = [:ccm89, :cal00, :od94]

function Aλ(wave::Number, Av::Real, Rv::Real, law::Symbol = :ccm89)
    @assert law in DUST_LAWS "$law not recognized. Please choose from $DUST_LAWS"
    if typeof(wave) <: Unitful.Quantity
        # Need to convert to anstrom natively
        wave = ustrip(u"angstrom", wave)
    end
    return Av * eval(law)(wave, Rv)
end

function _extinct(spec::Spectrum, Av::Real, Rv::Real = 3.1, law::Symbol = :ccm89) 
    factor = @. 10^(-0.4Aλ(spec.wave, Av, Rv, law))
    if eltype(spec.flux) <: Unitful.Quantity
        spec.flux .* factor * Unitful.NoUnits
    else
        spec.flux .* factor
    end
end

"""
    extinct(::Spectrum, Av::Real, Rv::Real=3.1; law=:ccm89)

Uses [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) to extinct a spectrum given the total extinction `Av` and the relative attenuation `Rv`. `law` must be one of the available extinction laws- currently `[:ccm89, :cal00, :od94]`. 
"""
function extinct(spec::Spectrum, Av::Real, Rv::Real = 3.1; law::Symbol = :ccm89)
    flux = _extinct(spec, Av, Rv, law)
    Spectrum(spec.wave, flux, spec.sigma, name = spec.name)
end

"""
    extinct!(::Spectrum, Av::Real, Rv::Real=3.1; law=:ccm89)

In-place version of `extinct`

# See Also
[`extinct`](@ref)
"""
function extinct!(spec::Spectrum, Av::Real, Rv::Real = 3.1; law::Symbol = :ccm89)
    spec.flux = _extinct(spec, Av, Rv, law)
end
