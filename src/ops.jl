using DustExtinction
using Unitful, UnitfulAstro
import Base

export extinct, extinct!

DUST_LAWS = [:ccm89, :cal00, :od94]

function Aλ(wave::AbstractArray, Rv::Real = 3.1, law::Symbol = :ccm89)
    @assert law in DUST_LAWS "$law not recognized. Please choose from $DUST_LAWS"
    if eltype(wave) <: Unitful.Unitlike
        wave = wave .|> u"angstrom"
    end
    eval(quote $law.(wave, Rv) end)
end

function _extinct(spec::Spectrum, Av::Real, Rv::Real = 3.1, law::Symbol = :ccm89) 
    factor = @. 10^(Av * Aλ(spec.wave, Rv, law))
    if eltype(spec.flux) <: Unitful.Unitlike
        factor *= unit(eltype(spec.flux))
    end
    return spec.flux * factor
end

"""
    extinct(spec::Spectrum, Av::Real, Rv::Real=3.1, law=:ccm89)
    extinct!(spec::Spectrum, Av::Real, Rv::Real=3.1, law=:ccm89)

Uses [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) to extinct a spectrum given the total extinction `Av` and the relative attenuation `Rv`. `law` must be one of the available extinction laws- currently `[:ccm89, :cal00, :od94]`. 
"""
function extinct(spec::Spectrum, Av::Real, Rv::Real = 3.1, law::Symbol = :ccm89)
    flux = _extinct(spec, Av, Rv, law)
    Spectrum(spec.wave, flux, spec.sigma, spec.mask, spec.name)
end

function extinct!(spec::Spectrum, Av::Real, Rv::Real = 3.1, law::Symbol = :ccm89)
    spec.flux = _extinct(spec, Av, Rv, law)
end
