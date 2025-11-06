const SingleSpectrum = Spectrum{W, F, 1, 1} where {W, F}

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
    w = wave(spec)
    f = flux(spec)
    println(io, "SingleSpectrum($(eltype(w)), $(eltype(f)))")
    println(io, "  wave $(size(w)): ", first(w), " .. ", last(w))
    println(io, "  flux $(size(f)): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end
