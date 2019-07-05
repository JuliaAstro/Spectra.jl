export Spectrum, wave, flux, sigma

import Base: ndims, size, length, show

mutable struct Spectrum
    wave::AbstractVector
    flux::AbstractVector
    sigma::AbstractVector
    mask::AbstractVector{Bool}
    name::String
    function Spectrum(wave::AbstractVector,
            flux::AbstractVector,
            sigma::AbstractVector,
            mask::AbstractVector{Bool},
            name::String)
        @assert size(wave) == size(flux) == size(sigma) == size(mask) "No ragged orders allowed"
        new(wave, flux, sigma, mask, name)
    end
end

"""
    Spectrum(wave::AbstractVector, flux::AbstractVector, [σ::AbstractVector, mask::AbstractVector{Bool}]; name::String)

A signle dimensional astronomical spectrum. If no sigma are provided, they are assumed to be unity. The mask is a positive mask, meaning that `true` will be included, rather than masked out. If no mask is provided, all `true` will be assumed. The name is an optional identifier for the Spectrum. Note that the dimensions of each array must be equal or an error will be thrown.

# Examples
```jldoctest
julia> wave = range(1e4, 4e4, length=1000);

julia> flux = randn(size(wave));

julia> spec = Spectrum(wave, flux)
Spectrum:

julia> spec = Spectrum(wave, flux, name="Just Noise")
Spectrum: Just Noise

```

There is easy integration with ``Unitful`` and its sub-projects
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = range(1u"μm", 4u"μm", length=1000) .|> u"angstrom";

julia> sigma = randn(size(wave))u"erg/cm^2/s/angstrom";

julia> flux = sigma .+ 100u"W/m^2/m"; # There will be implicit unit promotion

julia> unit(flux[1])
kg m^-1 s^-3

julia> spec = Spectrum(wave, flux, sigma, name="Unitful")
Spectrum: Unitful
```

If you want to apply the mask of a ``Spectrum``, use the functions corresponding to the respective field

```jldoctest
julia> wave = reshape(collect(range(1e4, 4e4, length=1000)), 2, :);

julia> sigma = randn(size(wave));

julia> flux = sigma .+ 100;

julia> mask = flux .> 0;

julia> spec = Spectrum(wave, flux, sigma, mask, name="Masked")
Spectrum: Masked
-----------------
Number of orders: 2

julia> wave(spec)
```
"""
function Spectrum(wave, 
    flux, 
    sigma, 
    mask ; 
    name::String = "")
    wave = Vector(wave)
    flux = Vector(flux)
    sigma = Vector(sigma)
    mask = Vector(mask)
    Spectrum(wave, flux, sigma, mask, name)
end
function Spectrum(wave::AbstractVector, 
        flux::AbstractVector, 
        sigma::AbstractVector, 
        mask::AbstractVector{Bool} ; 
        name::String = "")
   Spectrum(wave, flux, sigma, mask, name)
end

function Spectrum(wave::AbstractVector, 
        flux::AbstractVector, 
        sigma::AbstractVector ; 
        name::String = "")
    mask = trues(size(wave))
    return Spectrum(wave, flux, sigma, mask, name = name)
end

function Spectrum(wave::AbstractVector, flux::AbstractVector; name::String = "")
    sigma = fill!(similar(flux), 1)
    return Spectrum(wave, flux, sigma, name = name)
end

"""
    wave(::Spectrum)

Returns the masked wavelengths
"""
function wave(spec::Spectrum)
    return spec.wave[spec.mask]
end

"""
    flux(::Spectrum)

Returns the masked fluxes
"""
function flux(spec::Spectrum)
    return spec.flux[spec.mask]
end

"""
    sigma(::Spectrum)

Returns the masked sigma
"""
function sigma(spec::Spectrum)
    return spec.sigma[spec.mask]
end

function Base.show(io::IO, spec::Spectrum)
    println(io, "Spectrum: $(spec.name)")
end

"""
    ndims(::Spectrum)

Returns the number of dimensions of the Spectrum
"""
Base.ndims(spec::Spectrum) = 1

"""
    size(::Spectrum)

Returns the size, or dimensions, of the Spectrum
"""
Base.size(spec::Spectrum) = size(spec.wave)

"""
    length(::Spectrum)

Returns the length of the Spectrum
"""
Base.length(spec::Spectrum) = length(spec.wave)
