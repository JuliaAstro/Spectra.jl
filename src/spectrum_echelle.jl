"""
    EchelleSpectrum <: AbstractSpectrum

An instance of [`Spectrum`](@ref) where the spectral and flux axes are both 2D arrays, i.e., ``M = N = 2``.

The spectral and flux matrices are both ``m`` rows in wavelength by ``n`` columns in [echelle order](https://en.wikipedia.org/wiki/Echelle_grating).

# Examples

```jldoctest
julia> wave = reshape(1:40, 10, 4)
10×4 reshape(::UnitRange{Int64}, 10, 4) with eltype Int64:
  1  11  21  31
  2  12  22  32
  3  13  23  33
  4  14  24  34
  5  15  25  35
  6  16  26  36
  7  17  27  37
  8  18  28  38
  9  19  29  39
 10  20  30  40

julia> flux = repeat(1:4, 1, 10)'
10×4 adjoint(::Matrix{Int64}) with eltype Int64:
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4
 1  2  3  4

julia> spec = Spectrum(wave, flux, Dict())
EchelleSpectrum(Int64, Int64)
  # orders: 4
  spectral axis (10, 4): 1 .. 40
  flux axis (10, 4): 1 .. 4
  meta: Dict{Symbol, Any}()

julia> spec[1] # Indexing returns a `SingleSpectrum`
SingleSpectrum(Int64, Int64)
  spectral axis (10,): 1 .. 10
  flux axis (10,): 1 .. 1
  meta: Dict{Symbol, Any}(:Order => 1)
```

See [`SingleSpectrum`](@ref) for a 1D variant, and [`IFUSpectrum`](@ref) for a 3D variant.
"""
const EchelleSpectrum = Spectrum{W, F, 2, 2} where {W, F}

function Base.getindex(spec::EchelleSpectrum, i::Int)
    w = spectral_axis(spec)[:, i]
    f = flux_axis(spec)[:, i]
    m = merge(Dict(:Order => i), meta(spec))
    return Spectrum(w, f, m)
end

function Base.getindex(spec::EchelleSpectrum, I::AbstractVector)
    w = spectral_axis(spec)[:, I]
    f = flux_axis(spec)[:, I]
    m = merge(Dict(:Orders => (first(I), last(I))), meta(spec))
    return Spectrum(w, f, m)
end

Base.firstindex(spec::EchelleSpectrum) = firstindex(flux_axis(spec), 1)
Base.lastindex(spec::EchelleSpectrum) = lastindex(flux_axis(spec), 1)

function Base.show(io::IO, spec::EchelleSpectrum)
    w = spectral_axis(spec)
    f = flux_axis(spec)
    println(io, "EchelleSpectrum($(eltype(spectral_axis(spec))), $(eltype(flux_axis(spec))))")
    println(io, "  # orders: $(size(spec, 2))")
    println(io, "  spectral axis $(size(w)): ", first(w), " .. ", last(w))
    println(io, "  flux axis $(size(f)): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end
