using DustExtinction
using Unitful, UnitfulAstro

export extinct, extinct!

DUST_LAWS = [:ccm89, :cal00, :od94]

function Aλ(wave::AbstractArray, Rv::Real=3.1, law::Symbol=:ccm89)
    @assert law in DUST_LAWS "$law not recognized. Please choose from $DUST_LAWS"
    if eltype(wave) <: Unitful.Unitlike
        wave = wave .|> u"angstrom"
    end
    eval(quote $law.(wave, Rv) end)
end

_extinct(spec::Spectrum, Av::Real, Rv::Real=3.1, law::Symbol=:ccm89) = @. spec.flux * 10^(Av * Aλ(spec.wave, Rv, law))



function extinct(spec::Spectrum, Av::Real, Rv::Real=3.1, law::Symbol=:ccm89)
    flux = _extinct(spec, Av, Rv, law)
    Spectrum(spec.wave, flux, spec.sigma, spec.mask, spec.name)
end

function extinct!(spec::Spectrum, Av::Real, Rv::Real=3.1, law::Symbol=:ccm89)
    spec.flux = _extinct(spec, Av, Rv, law)
end
