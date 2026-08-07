"""
    BinnedSpectrum <: AbstractSpectrum

An instance of [`Spectrum`](@ref) where the spectral axis is an ``m x 2`` matrix of bin edges and the flux axis is a 1D array.
"""
const BinnedSpectrum = Spectrum{S, F, 2, 1} where {S, F}

function Base.getindex(spec::BinnedSpectrum, i::Int)
    return Spectrum(spectral_axis(spec)[i:i, :], flux_axis(spec)[i:i], meta(spec))
end

function Base.getindex(spec::BinnedSpectrum, inds)
    return Spectrum(spectral_axis(spec)[inds, :], flux_axis(spec)[inds], meta(spec))
end

Base.firstindex(spec::BinnedSpectrum) = firstindex(flux_axis(spec))
Base.lastindex(spec::BinnedSpectrum) = lastindex(flux_axis(spec))

function Base.show(io::IO, spec::BinnedSpectrum)
    w = spectral_axis(spec)
    f = flux_axis(spec)
    println(io, "BinnedSpectrum($(eltype(w)), $(eltype(f)))")
    println(io, "  spectral axis $(size(w)): ", w[1, 1], " .. ", w[end, 2])
    println(io, "  flux axis $(size(f)): ", first(f), " .. ", last(f))
    print(io, "  meta: ", meta(spec))
end

# rebinning -> important in the future, make sure rmf gets rebinned correctly or it could have different size
