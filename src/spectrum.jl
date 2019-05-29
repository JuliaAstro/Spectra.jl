export Spectrum, wave, flux, σ

using Unitful
import Base: show, size, length, ndims

mutable struct Spectrum
   wave::AbstractArray
   flux::AbstractArray
   σ::AbstractArray
   mask::AbstractArray{Bool}
   name::String
end

"""
    Spectrum(wave::AbstractArray, flux::AbstractArray; name::String)
    Spectrum(wave::AbstractArray, flux::AbstractArray, σ::AbstractArray; name::String)
    Spectrum(wave::AbstractArray, flux::AbstractArray, σ::AbstractArray, mask::AbstractArray{Bool}; name::String)

A spectrum which can have either 1 or 2 (Echelle) dimensions. If no σ are provided, they are assumed to be unity. The mask is a positive mask, meaning that `true` will be included, rather than masked out. If no mask is provided, all `true` will be assumed. The name is an optional identifier for the Spectrum. Note that the dimensions of each array must be equal or an error will be thrown.
"""
function Spectrum(wave::AbstractArray, flux::AbstractArray, σ::AbstractArray, mask::AbstractArray{Bool}; name::String="Spectrum")
    @assert size(wave) == size(flux) == size(σ) == size(mask)
    @assert ndims(wave) ∈ (1, 2)
    return Spectrum(wave, flux, σ, mask, name)
end
function Spectrum(wave::AbstractArray, flux::AbstractArray, σ::AbstractArray; name::String="Spectrum")
    @assert size(wave) == size(flux) == size(σ)
    mask = trues(size(wave))
    return Spectrum(wave, flux, σ, mask, name)
end

function Spectrum(wave::AbstractArray, flux::AbstractArray; name::String="Spectrum")
    @assert size(wave) == size(flux)
    σ = ones(eltype(flux), size(flux))
    mask = trues(size(wave))
    return Spectrum(wave, flux, σ, mask, name)
end

"""
    ndims(::Spectrum)

Returns the number of dimensions of the Spectrum
"""
function ndims(spec::Spectrum)
    return ndims(spec.wave)
end

"""
    size(::Spectrum)

Returns the size, or dimensions, of the Spectrum
"""
function size(spec::Spectrum)
    return size(spec.wave)
end

"""
    length(::Spectrum)

Returns the length of the Spectrum
"""
function length(spec::Spectrum)
    return length(spec.wave)
end

"""
    wave(::Spectrum)

Returns the masked wavelengths
"""
function wave(spec::Spectrum)
    return spec.wave[spec.mask]
end

"""
    flux(::Spectrum)

Returns the masked fluxes
"""
function flux(spec::Spectrum)
    return spec.flux[spec.mask]
end

"""
    σ(::Spectrum)

Returns the masked σ
"""
function σ(spec::Spectrum)
    return spec.σ[spec.mask]
end
