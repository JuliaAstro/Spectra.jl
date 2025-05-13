using WCS
using Unitful

export AbstractSpectrum
#--------------------------------------------------------------------------------------

"""
    AbstractSpectrum{W<:Number, F<:Number}

An abstract holder for astronomical spectra. All types inheriting from this must have the following fields

- wave::Array{W, N}
- flux::Array{F, N}
- meta::Dict{Symbol, Any}
"""
abstract type AbstractSpectrum{W,F} end

function Base.getproperty(spec::AbstractSpectrum, nm::Symbol)
    if nm in keys(getfield(spec, :meta))
        return getfield(spec, :meta)[nm]
    else
        return getfield(spec, nm)
    end
end

function Base.propertynames(spec::AbstractSpectrum)
    natural = (:wave, :flux, :meta)
    meta = keys(spec.meta)
    return (natural..., meta...)
end

"""
    wave(::AbstractSpectrum)

Return the wavelengths of the spectrum.
"""
wave(spec::AbstractSpectrum) = spec.wave

"""
    flux(::AbstractSpectrum)

Return the flux of the spectrum.
"""
flux(spec::AbstractSpectrum) = spec.flux

# Collection
Base.eltype(spec::AbstractSpectrum) = eltype(spec.flux)
Base.size(spec::AbstractSpectrum) = size(spec.flux)
Base.size(spec::AbstractSpectrum, i) = size(spec.flux, i)
Base.length(spec::AbstractSpectrum) = length(spec.flux)
Base.maximum(spec::AbstractSpectrum) = maximum(spec.flux)
Base.minimum(spec::AbstractSpectrum) = minimum(spec.flux)
Base.argmax(spec::AbstractSpectrum) = argmax(spec.flux)
Base.argmin(spec::AbstractSpectrum) = argmin(spec.flux)
Base.findmax(spec::AbstractSpectrum) = findmax(spec.flux)
Base.findmin(spec::AbstractSpectrum) = findmin(spec.flux)

# Arithmetic
Base.:+(s::T, A) where {T <: AbstractSpectrum} = T(s.wave, s.flux .+ A, s.meta)
Base.:*(s::T, A::AbstractVector) where {T <: AbstractSpectrum} = T(s.wave, s.flux .* A, s.meta)
Base.:/(s::T, A) where {T <: AbstractSpectrum} = T(s.wave, s.flux ./ A, s.meta)
Base.:-(s::T) where {T <: AbstractSpectrum} = T(s.wave, -s.flux, s.meta)
Base.:-(s::AbstractSpectrum, A) = s + -A
Base.:-(A, s::AbstractSpectrum) = s - A
Base.:-(s::AbstractSpectrum, o::AbstractSpectrum) = s - o # Satisfy Aqua

# Multi-Spectrum
Base.:+(s::T, o::T) where {T <: AbstractSpectrum} = T(s.wave, s.flux .+ o.flux, s.meta)
Base.:*(s::T, o::T) where {T <: AbstractSpectrum} = T(s.wave, s.flux .* o.flux, s.meta)
Base.:/(s::T, o::T) where {T <: AbstractSpectrum} = T(s.wave, s.flux ./ o.flux * unit(s)[2], s.meta)
Base.:-(s::T, o::T) where {T <: AbstractSpectrum} = T(s.wave, s.flux .- o.flux, s.meta)

"""
    Unitful.ustrip(::AbstractSpectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom")
Spectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(Å,), 𝐋, nothing}}, Quantity{Float64, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(Å^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> ustrip(spec)
Spectrum(Float64, Float64)
```
"""
Unitful.ustrip(spec::AbstractSpectrum) = spectrum(ustrip.(spec.wave), ustrip.(spec.flux); spec.meta...)

"""
    Unitful.unit(::AbstractSpectrum)

Get the units of a spectrum. Returns a tuple of the wavelength units and flux/sigma units

# Examples
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = spectrum(wave * u"angstrom", flux * u"W/m^2/angstrom");

julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)
```
"""
Unitful.unit(spec::AbstractSpectrum) = unit(eltype(spec.wave)), unit(eltype(spec.flux))
