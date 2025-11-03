const IFUSpectrum = Spectrum{W, F, 1, 2} where {W, F}

function Base.getindex(spec::IFUSpectrum, i::Int)
    w = wave(spec)
    f = flux(spec)[i, :]
    m = merge(Dict(:Order => i), meta(spec))
    return Spectrum(w, f, m)
end

function Base.getindex(spec::IFUSpectrum, i::Int, J::AbstractVector)
    w = wave(spec)
    f = flux(spec)[i, J]
    m = merge(Dict(:Order => i), meta(spec))
    return Spectrum(w, f, m)
end

function Base.getindex(spec::IFUSpectrum, I::AbstractVector)
    w = wave(spec)[I]
    f = flux(spec)[I, :]
    m = merge(Dict(:Orders => (first(I), last(I))), meta(spec))
    return Spectrum(w, f, m)
end

Base.firstindex(spec::IFUSpectrum) = firstindex(flux(spec), 1)
Base.firstindex(spec::IFUSpectrum, dim::Int) = firstindex(flux(spec), dim)
Base.lastindex(spec::IFUSpectrum) = lastindex(flux(spec), 1)

function Base.show(io::IO, spec::IFUSpectrum)
    println(io, "IFUSpectrum($(eltype(wave(spec))), $(eltype(flux(spec))))")
    println(io, "  # orders: $(size(spec, 1))")
    println(io, "  wave: ", (extrema∘wave)(spec))
    print(io, "  meta: ", meta(spec))
end
