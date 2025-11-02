const SingleSpectrum = Spectrum{W, F, 1} where {W, F}

#Base.size(spec::SingleSpectrum) = (length(wave(spec)), )
#Base.IndexStyle(::Type{<:SingleSpectrum}) = IndexLinear()

function Base.getindex(spec::SingleSpectrum, i::Int)
    return Spectrum([wave(spec)[i]], [flux(spec)[i]], meta(spec))
end

function Base.getindex(spec::SingleSpectrum, inds)
    return Spectrum(wave(spec)[inds], flux(spec)[inds], meta(spec))
end

Base.firstindex(spec::SingleSpectrum) = firstindex(wave(spec))
Base.lastindex(spec::SingleSpectrum) = lastindex(wave(spec))

function Base.show(io::IO, spec::SingleSpectrum)
    println(io, "SingleSpectrum($(eltype(wave(spec))), $(eltype(flux(spec))))")
    println(io, "  wave: ", (extrema∘wave)(spec))
    println(io, "  flux: ", (extrema∘flux)(spec))
    print(io, "  meta: ", meta(spec))
end
