struct EchelleSpectrum{W <: Number,F <: Number} <: AbstractSpectrum{W,F}
    wave::Matrix{W}
    flux::Matrix{F}
    meta::Dict{Symbol,Any}
end

EchelleSpectrum(wave, flux, meta::Dict{Symbol,Any}) = EchelleSpectrum(collect(wave), collect(flux), meta)

function Base.show(io::IO, spec::EchelleSpectrum)
    println(io, "EchelleSpectrum($(eltype(spec.wave)), $(eltype(spec.flux)))")
    print(io, "  # orders: $(size(spec, 1))")
    for (key, val) in spec.meta
        print(io, "\n  $key: $val")
    end
end

function Base.getindex(spec::EchelleSpectrum, i::Integer)
    wave = spec.wave[i, :]
    flux = spec.flux[i, :]
    meta = merge(Dict(:Order => i), spec.meta)
    return Spectrum(wave, flux, meta)
end

function Base.getindex(spec::EchelleSpectrum, I::AbstractVector)
    waves = spec.wave[I, :]
    flux = spec.flux[I, :]
    meta = merge(Dict(:Orders => (first(I), last(I))), spec.meta)
    return EchelleSpectrum(waves, flux, meta)
end

Base.lastindex(spec::EchelleSpectrum) = lastindex(spec.flux, 1)
