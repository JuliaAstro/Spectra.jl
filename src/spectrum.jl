"""
    Spectrum <: AbstractSpectrum

A 1-dimensional spectrum stored as vectors of real numbers. The wavelengths are assumed to be in angstrom.
"""
mutable struct Spectrum{W <: Number,F <: Number} <: AbstractSpectrum{W,F}
    wave::Vector{W}
    flux::Vector{F}
    meta::Dict{Symbol,Any}
end

Spectrum(wave, flux, meta::Dict{Symbol,Any}) = Spectrum(collect(wave), collect(flux), meta)

Base.size(spec::Spectrum) = (length(spec.wave), )
Base.IndexStyle(::Type{<:Spectrum}) = IndexLinear()

function Base.getindex(spec::Spectrum, i::Int)
    return Spectrum([spec.wave[i]], [spec.flux[i]], spec.meta)
end

function Base.getindex(spec::Spectrum, inds)
    return Spectrum(spec.wave[inds], spec.flux[inds], spec.meta)
end

Base.firstindex(spec::Spectrum) = firstindex(spec.wave)
Base.lastindex(spec::Spectrum) = lastindex(spec.wave)

function Base.show(io::IO, spec::Spectrum)
    print(io, "Spectrum($(eltype(spec.wave)), $(eltype(spec.flux)))")
    for (key, val) in spec.meta
        print(io, "\n  $key: $val")
    end
end
