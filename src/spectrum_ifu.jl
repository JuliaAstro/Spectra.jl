const IFUSpectrum = Spectrum{W, F, 1, 3} where {W, F}

Base.getindex(spec::IFUSpectrum, i::Int, j, k) = flux(spec)[i, j, k]

function Base.getindex(spec::IFUSpectrum, i, j, k)
    w = wave(spec)[i]
    f = flux(spec)[i, j, k]
    return Spectrum(w, f, meta(spec))
end

Base.firstindex(spec::IFUSpectrum, i) = firstindex(flux(spec), i)
Base.lastindex(spec::IFUSpectrum, i) = lastindex(flux(spec), i)

function Base.show(io::IO, spec::IFUSpectrum)
    w = wave(spec)
    f = flux(spec)
    println(io, "IFUSpectrum($(eltype(w)), $(eltype(f)))")
    println(io, "  wave ($(size(w))): ", first(w), " .. ", last(w))
    println(io, "  flux ($(size(f))): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end
