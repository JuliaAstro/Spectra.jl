"""
    SingleSpectrum <: AbstractSpectrum

An instance of [`Spectrum`](@ref) where the spectral and flux axes are both 1D arrays, i.e., ``M = N = 1``.

Both spectral and flux axis vectors must have the same length, ``m = n``, respectively.

# Examples

```jldoctest
julia> spec = Spectrum([6, 7, 8, 9], [2, 3, 4, 5], Dict())
SingleSpectrum(Int64, Int64)
  spectral axis (4,): 6 .. 9
  flux axis (4,): 2 .. 5
  meta: Dict{Symbol, Any}()
```

See [`EchelleSpectrum`](@ref) and [`IFUSpectrum`](@ref) for working with instances of higher dimensional spectra.
"""
const SingleSpectrum = Spectrum{S, F, 1, 1} where {S, F}

#Base.size(spec::SingleSpectrum) = (length(spectral_axis(spec)), )
#Base.IndexStyle(::Type{<:SingleSpectrum}) = IndexLinear()

function Base.getindex(spec::SingleSpectrum, i::Int)
    return Spectrum([spectral_axis(spec)[i]], [flux_axis(spec)[i]], meta(spec))
end

function Base.getindex(spec::SingleSpectrum, inds)
    return Spectrum(spectral_axis(spec)[inds], flux_axis(spec)[inds], meta(spec))
end

Base.firstindex(spec::SingleSpectrum) = firstindex(spectral_axis(spec))
Base.lastindex(spec::SingleSpectrum) = lastindex(spectral_axis(spec))

function Base.show(io::IO, spec::SingleSpectrum)
    w = spectral_axis(spec)
    f = flux_axis(spec)
    println(io, "SingleSpectrum($(eltype(w)), $(eltype(f)))")
    println(io, "  spectral axis $(size(w)): ", first(w), " .. ", last(w))
    println(io, "  flux axis $(size(f)): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end
