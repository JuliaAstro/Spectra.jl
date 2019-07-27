export Spectrum

import Base: size, length

mutable struct Spectrum{W <: Number,F <: Number}
    wave::AbstractVector{W}
    flux::AbstractVector{F}
    sigma::AbstractVector{F}
    name::String
    function Spectrum(wave::AbstractVector{W},
            flux::AbstractVector{F},
            sigma::AbstractVector{F},
            name::String) where {W <: Number,F <: Number}
        @assert size(wave) == size(flux) == size(sigma) "No ragged orders allowed"
        new{W,F}(wave, flux, sigma, name)
    end
end

"""
    Spectrum(wave::AbstractVector{W}, flux::AbstractVector{F}, [sigma::AbstractVector{F}]; name::String)

A signle dimensional astronomical spectrum. If no sigma are provided, they are assumed to be unity. The name is an optional identifier for the Spectrum. Note that the dimensions of each array must be equal or an error will be thrown.

# Examples
```jldoctest
julia> wave = range(1e4, 4e4, length=1000);

julia> flux = randn(size(wave));

julia> spec = Spectrum(wave, flux)
Spectrum:

julia> spec = Spectrum(wave, flux, name="Just Noise")
Spectrum: Just Noise

```

There is easy integration with ``Unitful`` and its sub-projects
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = range(1u"μm", 4u"μm", length=1000) .|> u"angstrom";

julia> sigma = randn(size(wave))u"erg/cm^2/s/angstrom";

julia> flux = sigma .+ 100u"W/m^2/m"; # There will be implicit unit promotion

julia> unit(flux[1])
kg m^-1 s^-3

julia> spec = Spectrum(wave, flux, sigma, name="Unitful")
Spectrum: Unitful
```
"""
function Spectrum(wave, 
    flux, 
    sigma ; 
    name::String = "")
    wave = Vector(wave)
    flux = Vector(flux)
    sigma = Vector(sigma)
    Spectrum(wave, flux, sigma, name)
end

function Spectrum(wave::AbstractVector, 
        flux::AbstractVector, 
        sigma::AbstractVector ; 
        name::String = "")
   Spectrum(wave, flux, sigma, name)
end

function Spectrum(wave::AbstractVector, flux::AbstractVector; name::String = "")
    sigma = fill!(similar(flux), 1)
    return Spectrum(wave, flux, sigma, name = name)
end


Base.size(spec::Spectrum) = size(spec.wave)
Base.length(spec::Spectrum) = length(spec.wave)

# Arithmetic
Base.:+(s::Spectrum, A) = Spectrum(s.wave, s.flux .+ A, s.sigma, s.name)
Base.:*(s::Spectrum, A) = Spectrum(s.wave, s.flux .* A, s.sigma .* abs.(A), s.name)
Base.:/(s::Spectrum, A) = Spectrum(s.wave, s.flux ./ A, s.sigma ./ abs.(A), s.name)
Base.:-(s::Spectrum, A) = s + -A
