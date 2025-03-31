using LinearAlgebra

export continuum, line_flux, equivalent_width

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

function chebfit(wave, flux::AbstractVector{T}, deg) where {T}
    # gotta be a simpler way to convert to -1 to 1 domain
    x = (wave .- minimum(wave)) .* 2 ./ (maximum(wave) - minimum(wave)) .- 1
    vand = chebvander(x, deg)
    if T <: Measurement
        W = diagm(0 => Measurements.uncertainty.(flux))
        coeffs = (vand' * W * vand) \ (vand' * W * flux)
    else
        coeffs = pinv(vand) * flux
    end
    fit = vand * coeffs
    return coeffs, fit
end

"""
    continuum!(::AbstractSpectrum, deg::Int=3)

In-place version of [`continuum`](@ref)
"""
function continuum!(spec::AbstractSpectrum, deg::Int = 3)
    coeffs, fit = chebfit(spec.wave, spec.flux, deg)
    spec.flux .= spec.flux ./ ustrip.(fit)
    merge!(spec.meta, Dict(:normalized => true, :coeffs => coeffs))
    return spec
end

"""
    continuum(::AbstractSpectrum, deg::Int=3)

Return a continuum-normalized spectrum by fitting the continuum with a Chebyshev polynomial of degree `deg`.
"""
continuum(spec::AbstractSpectrum, deg::Int = 3) = continuum!(deepcopy(spec), deg)

"""
    equivalent_width(::AbstractSpectrum)

Calculate the equivalent width of the given continuum-normalized spectrum. Return value has units equal to wavelengths.
"""
function equivalent_width(spec::AbstractSpectrum)
    dx = spec.wave[end] - spec.wave[1]
    flux = ustrip(line_flux(spec))
    return dx - flux * unit(dx)
end

"""
    line_flux(::AbstractSpectrum)

Calculate the line flux of the given continuum-normalized spectrum. Return value has units equal to flux.
"""
function line_flux(spec::AbstractSpectrum)
    avg_dx = diff(spec.wave)
    return sum(spec.flux[2:end] .* avg_dx)
end
