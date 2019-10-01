using LinearAlgebra
export continuum, line_flux, equivalent_width, Region

function chebvander(x::AbstractVector{T}, deg::Int) where {T <: Number}
    v = Matrix{T}(undef, length(x), deg + 1)
    v[:, 1] .= one(T)
    x2 = 2 .* x
    v[:, 2] .= x
    @inbounds for i in 3:deg + 1
        v[:, i] .= v[:, i - 1] .* x2 .- v[:, i - 2]
    end
    return v
end

function chebfit(wave, flux, deg)
    x = wave .* 2 ./ sum(wave) .- 1
    vand = chebvander(x, deg)
    coeffs = pinv(vand) * flux
    fit = vand * coeffs
    return coeffs, fit
end

"""
    continuum!(::AbstractSpectrum, deg::Int=3)

In-place version of [`continuum`](@ref)
"""
function continuum!(spec::T, deg::Int = 3) where {T <: AbstractSpectrum}
    coeffs, fit = chebfit(spec.wave, spec.flux, deg)
    spec.flux .= spec.flux ./ fit
    merge!(spec.meta, Dict(:normalized => true, :coeffs => coeffs))
    return spec
end

"""
    continuum(::AbstractSpectrum, deg::Int=3)

Return a continuum-normalized spectrum by fitting the continuum with a Chebyshev polynomial of degree `deg`. 
"""
continuum(spec::T, deg::Int = 3) where {T <: AbstractSpectrum} = continuum!(deepcopy(spec), deg)

function continuum!(spec::UnitfulSpectrum, deg::Int = 3)
    strip_spec = ustrip(spec)
    coeffs, fit = chebfit(strip_spec.wave, strip_spec.flux, deg)
    spec.flux .= spec.flux ./ fit
    merge!(spec.meta, Dict(:normalized => true, :coeffs => coeffs))
    return spec
end

continuum(spec::UnitfulSpectrum, deg::Int = 3) = continuum!(deepcopy(spec), deg)

"""
    equivalent_width(::AbstractSpectrum)

Calculate the equivalent width of the given continuum-normalized spectrum. Return value has units equal to wavelengths.
"""
function equivalent_width(spec::T) where {T <: AbstractSpectrum}
    dx = spec.wave[end] - spec.wave[1]
    flux = ustrip(line_flux(spec))
    return dx - flux * unit(dx)
end

"""
    line_flux(::AbstractSpectrum)

Calculate the line flux of the given continuum-normalized spectrum. Return value has units equal to flux.
"""
function line_flux(spec::T) where {T <: AbstractSpectrum}
    avg_dx = spec.wave[2:end] .- spec.wave[1:end - 1]
    return sum(spec.flux[2:end] .* avg_dx)
end

"""
    Region(low, high)

A simple bandpass.

# Examples
```julia
line = spec * Region(6540, 6550)
```
"""
struct Region{T}
    low::T
    high::T
end

function Base.show(io::IO, r::Region)
    print(io, "[$(r.low), $(r.high)]")
end

function Base.:*(spec::T, r::Region) where {T <: AbstractSpectrum}
    mask = r.low .≤ spec.wave .≤  r.high
    wave = spec.wave[mask]
    flux = spec.flux[mask]
    meta = merge(spec.meta, Dict(:region => r))
    return T(wave, flux, meta)
end
