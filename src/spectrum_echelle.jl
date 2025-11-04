const EchelleSpectrum = Spectrum{W, F, 2, 2} where {W, F}

function Base.getindex(spec::EchelleSpectrum, i::Int)
    w = wave(spec)[i, :]
    f = flux(spec)[i, :]
    m = merge(Dict(:Order => i), meta(spec))
    return Spectrum(w, f, m)
end

function Base.getindex(spec::EchelleSpectrum, I::AbstractVector)
    w = wave(spec)[I, :]
    f = flux(spec)[I, :]
    m = merge(Dict(:Orders => (first(I), last(I))), meta(spec))
    return Spectrum(w, f, m)
end

Base.firstindex(spec::EchelleSpectrum) = firstindex(flux(spec), 1)
Base.lastindex(spec::EchelleSpectrum) = lastindex(flux(spec), 1)

function Base.show(io::IO, spec::EchelleSpectrum)
    w = wave(spec)
    f = flux(spec)
    println(io, "EchelleSpectrum($(eltype(wave(spec))), $(eltype(flux(spec))))")
    println(io, "  # orders: $(size(spec, 1))")
    println(io, "  wave ($(size(w))): ", first(w), " .. ", last(w))
    println(io, "  flux ($(size(f))): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end
