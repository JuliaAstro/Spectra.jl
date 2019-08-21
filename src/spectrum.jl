export Spectrum, unit, ustrip

import Base: size, length
import Unitful

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
    Spectrum(wave, flux, [sigma]; name="")

A signle dimensional astronomical spectrum. If no sigma are provided, they are assumed to be unity. The name is an optional identifier for the Spectrum. Note that the dimensions of each array must be equal or an error will be thrown.

# Examples
```jldoctest
julia> using Spectra

julia> wave = range(1e4, 4e4, length=1000);

julia> flux = randn(size(wave));

julia> spec = Spectrum(wave, flux)
Spectrum:

julia> spec = Spectrum(wave, flux, name="Just Noise")
Spectrum: Just Noise

```

There is easy integration with `Unitful` and its sub-projects
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

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
    flux, sigma = promote(flux, sigma)
    flux = Vector(flux)
    sigma = Vector(sigma)
    Spectrum(wave, flux, sigma, name)
end

function Spectrum(wave::AbstractVector, 
        flux::AbstractVector, 
        sigma::AbstractVector ; 
        name::String = "")
   flux, sigma = promote(flux, sigma)
   Spectrum(wave, flux, sigma, name)
end

function Spectrum(wave::AbstractVector, flux::AbstractVector; name::String = "")
    fill_val = eltype(flux) <: Quantity ? 1*unit(eltype(flux)) : 1
    sigma = repeat([fill_val], length(flux))
    return Spectrum(wave, flux, sigma, name = name)
end

function Base.show(io::IO, spec::Spectrum)
    println(io, "Spectrum: $(spec.name)")
end

"""
    size(::Spectrum)
"""
Base.size(spec::Spectrum) = size(spec.wave)

"""
    length(::Spectrum)
"""
Base.length(spec::Spectrum) = length(spec.wave)


"""
    Unitful.ustrip(::Spectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000) |> collect;

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = Spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom")
Spectrum:


julia> strip_spec = ustrip(spec)
Spectrum: 


```
"""
Unitful.ustrip(spec::Spectrum) = Spectrum(ustrip.(spec.wave), ustrip.(spec.flux), ustrip.(spec.sigma), name = spec.name)

"""
    Unitful.unit(::Spectrum)

Get the units of a spectrum. Returns a tuple of the wavelength units and flux/sigma units

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000) |> collect;

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = Spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom")
Spectrum:


julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)

```
"""
Unitful.unit(spec::Spectrum) = Tuple(unit.(typeof(spec).parameters))

# Arithmetic
Base.:+(s::Spectrum, A) = Spectrum(s.wave, s.flux .+ A, s.sigma, name = s.name)
Base.:*(s::Spectrum, A) = Spectrum(s.wave, s.flux .* A, s.sigma .* abs.(A), name = s.name)
Base.:/(s::Spectrum, A) = Spectrum(s.wave, s.flux ./ A, s.sigma ./ abs.(A), name = s.name)
Base.:-(s::Spectrum, A) = s + -A

