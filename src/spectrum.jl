export Spectrum, wave, flux, σ

import Base: show, size, length

mutable struct Spectrum{T<:Real}
   wave::AbstractArray{T}
   flux::AbstractArray{T}
   σ::AbstractArray{T}
   mask::AbstractArray{Bool}
   name::String
end

function Spectrum(wave::AbstractArray{T}, flux::AbstractArray{T}, σ::AbstractArray{T}, mask::AbstractArray{Bool}; name::String="") where T <: Real
    @assert size(wave) == size(flux) == size(σ) == size(mask)
    return Spectrum(wave, flux, σ, mask, name)
end
function Spectrum(wave::AbstractArray{T}, flux::AbstractArray{T}, σ::AbstractArray{T}; name::String="") where T <: Real
    @assert size(wave) == size(flux) == size(σ)
    mask = trues(size(wave))
    return Spectrum(wave, flux, σ, mask, name)
end

function Spectrum(wave::AbstractArray{T}, flux::AbstractArray{T}; name::String="") where T <: Real
    @assert size(wave) == size(flux)
    σ = ones(T, size(wave))
    mask = trues(size(wave))
    return Spectrum(wave, flux, σ, mask, name)
end

function size(spec::Spectrum)
    return size(spec.wave)
end

function length(spec::Spectrum)
    return length(spec.wave)
end

function wave(spec::Spectrum)
    return spec.wave[spec.mask]
end

function flux(spec::Spectrum)
    return spec.flux[spec.mask]
end

function σ(spec::Spectrum)
    return spec.σ[spec.mask]
end


