"""
    IFUSpectrum <: AbstractSpectrum

An instance of [`Spectrum`](@ref) where the wavelength is a 1D array and flux is a 3D array, i.e., ``M = 1`` and ``N = 3``.

The wavelength vector is of length ``m`` and flux 3D array has shape ``(m \\times n \\times k)`` where each entry of the flux along the wavelength axis is an ``n \\times k`` matrix.

# Examples

```jldoctest
julia> using Random

julia> rng = Random.seed!(0)
TaskLocalRNG()

julia> wave, flux = [20, 40, 120, 160, 200], rand(rng, 5, 10, 6);

julia> spec = Spectrum(wave, flux, Dict())
IFUSpectrum(Int64, Float64)
  wave (5,): 20 .. 200
  flux (5, 10, 6): 0.4552384158732863 .. 0.11698905483599475
  meta: Dict{Symbol, Any}()

julia> spec[begin] # IFU image at first wavelength
10×6 Matrix{Float64}:
 0.455238   0.828104   0.735106   0.042069  0.554894  0.0715802
 0.746943   0.149248   0.864755   0.116243  0.519913  0.310438
 0.0997382  0.523732   0.315933   0.935547  0.274589  0.250664
 0.470257   0.654557   0.351769   0.812597  0.158201  0.617466
 0.678779   0.312182   0.0568161  0.622296  0.61899   0.191777
 0.385452   0.345902   0.448835   0.041962  0.458694  0.791756
 0.908402   0.609104   0.108874   0.430905  0.91365   0.430885
 0.0256413  0.0831649  0.179467   0.799997  0.982336  0.721449
 0.408092   0.361884   0.849442   0.527004  0.341892  0.499461
 0.239929   0.3754     0.247219   0.92438   0.733984  0.432918

julia> spec[begin:3] # IFU spectrum at first three wavelengths
IFUSpectrum(Int64, Float64)
  wave (3,): 20 .. 120
  flux (3, 10, 6): 0.4552384158732863 .. 0.35149138733595564
  meta: Dict{Symbol, Any}()

julia> spec[:, begin, begin] # 1D spectrum at spaxel (1, 1)
SingleSpectrum(Int64, Float64)
  wave (5,): 20 .. 200
  flux (5,): 0.4552384158732863 .. 0.02964765308691042
  meta: Dict{Symbol, Any}()
```

See [`SingleSpectrum`](@ref) for a 1D variant, and [`EchelleSpectrum`](@ref) for a 2D variant.
"""
const IFUSpectrum = Spectrum{W, F, 1, 3} where {W, F}

Base.getindex(spec::IFUSpectrum, i) = flux(spec)[i, :, :]

function Base.getindex(spec::IFUSpectrum, I::AbstractVector)
    w = wave(spec)[I]
    f = flux(spec)[I, :, :]
    return Spectrum(w, f, meta(spec))
end

Base.getindex(spec::IFUSpectrum, i::Int, j, k) = flux(spec)[i, j, k]

function Base.getindex(spec::IFUSpectrum, i, j, k)
    w = wave(spec)[i]
    f = flux(spec)[i, j, k]
    return Spectrum(w, f, meta(spec))
end

Base.firstindex(spec::IFUSpectrum) = firstindex(flux(spec))
Base.firstindex(spec::IFUSpectrum, i) = firstindex(flux(spec), i)
Base.lastindex(spec::IFUSpectrum, i) = lastindex(flux(spec), i)

function Base.show(io::IO, spec::IFUSpectrum)
    w = wave(spec)
    f = flux(spec)
    println(io, "IFUSpectrum($(eltype(w)), $(eltype(f)))")
    println(io, "  wave $(size(w)): ", first(w), " .. ", last(w))
    println(io, "  flux $(size(f)): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end
