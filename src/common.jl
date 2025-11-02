"""
    AbstractSpectrum{W<:Number, F<:Number}

An abstract holder for astronomical spectra. All types inheriting from this must have the following fields

- wave::Array{W, N}
- flux::Array{F, N}
- meta::Dict{Symbol, Any}
"""
abstract type AbstractSpectrum{W,F} end

"""
    Spectrum <: AbstractSpectrum

A spectrum or spectra stored as arrays of real numbers. The wavelengths are assumed to be in angstrom.
"""
mutable struct Spectrum{W<:Number, F<:Number, N} <: AbstractSpectrum{W, F}
    wave::AbstractArray{W, N}
    flux::AbstractArray{F, N}
    meta::Dict{Symbol,Any}
end

Spectrum(wave, flux, meta::Dict{Symbol, Any}) = Spectrum(collect(wave), collect(flux), meta)

function Base.getproperty(spec::AbstractSpectrum, nm::Symbol)
    if nm in keys(getfield(spec, :meta))
        return getfield(spec, :meta)[nm]
    else
        return getfield(spec, nm)
    end
end

function Base.propertynames(spec::AbstractSpectrum)
    natural = (:wave, :flux, :meta)
    meta = keys(meta(spec))
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

"""
    meta(::AbstractSpectrum)

Return the meta of the spectrum.
"""
meta(spec::AbstractSpectrum) = spec.meta

# Collection
Base.eltype(spec::AbstractSpectrum) = eltype(flux(spec))
Base.size(spec::AbstractSpectrum) = size(flux(spec))
Base.size(spec::AbstractSpectrum, i) = size(flux(spec), i)
Base.length(spec::AbstractSpectrum) = length(flux(spec))
Base.maximum(spec::AbstractSpectrum) = maximum(flux(spec))
Base.minimum(spec::AbstractSpectrum) = minimum(flux(spec))
Base.argmax(spec::AbstractSpectrum) = argmax(flux(spec))
Base.argmin(spec::AbstractSpectrum) = argmin(flux(spec))
Base.findmax(spec::AbstractSpectrum) = findmax(flux(spec))
Base.findmin(spec::AbstractSpectrum) = findmin(flux(spec))

# Arithmetic
Base.:+(s::T, A) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .+ A, meta(s))
Base.:*(s::T, A::Union{Real, AbstractVector}) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .* A, meta(s))
Base.:/(s::T, A) where {T <: AbstractSpectrum} = T(wave(s), flux(s) ./ A, meta(s))
Base.:-(s::T) where {T <: AbstractSpectrum} = T(wave(s), -flux(s), meta(s))
Base.:-(s::AbstractSpectrum, A) = s + -A
Base.:-(A, s::AbstractSpectrum) = s - A
Base.:-(s::AbstractSpectrum, o::AbstractSpectrum) = s - o # Satisfy Aqua

# Multi-Spectrum
Base.:+(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .+ flux(s), meta(s))
Base.:*(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .* flux(s), meta(s))
Base.:/(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) ./ flux(s) * unit(s)[2], meta(s))
Base.:-(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .- flux(s), meta(s))

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
Unitful.ustrip(spec::AbstractSpectrum) = spectrum(ustrip.(wave(spec)), ustrip.(flux(spec)); meta(spec)...)

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
Unitful.unit(spec::AbstractSpectrum) = unit(eltype(wave(spec))), unit(eltype(flux(spec)))
