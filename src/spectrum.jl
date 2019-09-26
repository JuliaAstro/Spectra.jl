using WCS, Unitful

export Spectrum, unit, ustrip, SpectralAxis

import Base
import Unitful
using PhysicalConstants.CODATA2018: c_0

mutable struct SpectralAxis
    λ::Vector{<:Quantity}
    ν::Vector{<:Quantity}
    function SpectralAxis(λ::Vector{<:Quantity}, ν::Vector{<:Quantity})
        @assert size(λ) == size(ν) "λ and ν must have same size"
        return new(λ, ν)
    end
end

SpectralAxis(λ, ν) = SpectralAxis(collect(λ), collect(ν))

function SpectralAxis(;λ=nothing, ν=nothing)
    if !isnothing(λ) && !isnothing(ν)
        return SpectralAxis(λ, ν)
    elseif isnothing(ν)
        ν = c_0 ./ λ .|> u"Hz"
    elseif isnothing(λ)
        λ = c_0 ./ ν .|> u"m"
    else
        error("Must supply either λ or ν")
    end
    return SpectralAxis(λ, ν)
end

function SpectralAxis(wcs::WCSTransform)
    # TODO
end


#########
#Spectrum
#########
abstract type AbstractSpectrum end

mutable struct Spectrum <: AbstractSpectrum
    flux::AbstractVector{<:Quantity}
    spectral::SpectralAxis
    meta::Dict
end


"""
    Spectrum(wave, flux; name="")

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

julia> sigma = randn(size(wave));

julia> flux = (100 .± sigma)u"erg/cm^2/s/angstrom"; # There will be implicit unit promotion

julia> unit(flux[1])
kg m^-1 s^-3

julia> spec = Spectrum(wave, flux, name="Unitful")
Spectrum: Unitful
```
"""
function Spectrum(wave::AbstractVector, 
        flux::AbstractVector;
        name::String = "")
   Spectrum(wave, flux, name)
end

function Base.show(io::IO, spec::Spectrum)
    println(io, "Spectrum: $(spec.name)")
    if eltype(spec.wave) <: Quantity
        wtype, ftype = unit(spec)
    else
        wtype = eltype(spec.wave)
        ftype = eltype(spec.flux)
    end
    println(io, "  λ ($wtype) f ($ftype)")
end

"""
    size(::Spectrum)
"""
Base.size(spec::Spectrum) = size(spec.flux)

"""
    length(::Spectrum)
"""
Base.length(spec::Spectrum) = length(spec.flux)


"""
    Unitful.ustrip(::Spectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000) |> collect;

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = Spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom");

julia> strip_spec = ustrip(spec);

```
"""
Unitful.ustrip(spec::Spectrum) = Spectrum(ustrip.(spec.wave), ustrip.(spec.flux), name = spec.name)

"""
    Unitful.unit(::Spectrum)

Get the units of a spectrum. Returns a tuple of the wavelength units and flux/sigma units

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000) |> collect;

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = Spectrum(wave * u"angstrom", flux * u"W/m^2/angstrom");

julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)

```
"""
Unitful.unit(spec::Spectrum) = Tuple(unit.(typeof(spec).parameters))

# Arithmetic
Base.:+(s::Spectrum, A) = Spectrum(s.wave, s.flux .+ A, name = s.name)
Base.:*(s::Spectrum, A) = Spectrum(s.wave, s.flux .* A, name = s.name)
Base.:/(s::Spectrum, A) = Spectrum(s.wave, s.flux ./ A, name = s.name)
Base.:-(s::Spectrum) = Spectrum(s.wave, -s.flux, name=s.name)
Base.:-(s::Spectrum, A) = Spectrum(s.wave, s.flux .- A, name=s.name)
