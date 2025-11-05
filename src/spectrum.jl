"""
    Spectrum <: AbstractSpectrum

A 1-dimensional spectrum stored as vectors of real numbers. The wavelengths are assumed to be in angstrom.
"""
struct Spectrum{W <: Number,F <: Number} <: AbstractSpectrum{W,F}
    wave::Vector{W}
    flux::Vector{F}
    meta::Dict{Symbol,Any}
end

Spectrum(wave, flux, meta::Dict{Symbol,Any}) = Spectrum(collect(wave), collect(flux), meta)

function Base.show(io::IO, spec::Spectrum)
    print(io, "Spectrum($(eltype(spec.wave)), $(eltype(spec.flux)))")
    for (key, val) in spec.meta
        print(io, "\n  $key: $val")
    end
end
