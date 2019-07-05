export Order, Spectrum, wave, flux, σ

using Unitful
import Base

mutable struct Order
    wave::AbstractVector
    flux::AbstractVector
    sigma::AbstractVector
    mask::AbstractVector{Bool}
    function Order(w, f, s, m)
        @assert size(w) == size(f) == size(s) == size(m) "No ragged orders allowed"
        new(w, f, s, m)
    end
end

function Order(wave::AbstractVector{W}, flux::AbstractVector{F}, sigma::AbstractVector{S}) where {W<:Number, F<:Number, S<:Number}
    Order(wave, promote(flux, sigma)...)
end

function Order(wave, flux, sigma)
    mask = trues(size(wave))
    Order(wave, flux, sigma, mask)
end

function Order(wave, flux)
    sigma = ones(eltype(flux), size(flux))
    Order(wave, flux, sigma)
end

Base.size(o::Order) = size(o.wave)
Base.ndims(o::Order) = ndims(o.wave)
Base.length(o::Order) = length(o.wave)

mutable struct Spectrum
    orders::AbstractArray{Order, 2}
    name::String
end

function Spectrum(orders::AbstractArray{Order, 2}; name="")
    Spectrum(orders, name)
end


"""
    Spectrum(wave::AbstractArray, flux::AbstractArray, [σ::AbstractArray, mask::AbstractArray{Bool}]; name::String)

A spectrum which can have either 1 or 2 (Echelle) dimensions. If no σ are provided, they are assumed to be unity. The mask is a positive mask, meaning that `true` will be included, rather than masked out. If no mask is provided, all `true` will be assumed. The name is an optional identifier for the Spectrum. Note that the dimensions of each array must be equal or an error will be thrown.

# Examples
```jldoctest
julia> wave = collect(range(1e4, 4e4, length=1000));

julia> flux = randn(size(wave));

julia> spec = Spectrum(wave, flux)
Spectrum: 
----------
Number of orders: 1

julia> spec = Spectrum(wave, flux, name="Just Noise")
Spectrum: Just Noise
--------------------
Number of orders: 1

```
Using a 2-dimensional (Echelle) spectrum
```jldoctest
julia> wave = reshape(collect(range(1e4, 4e4, length=1000)), 2, :);

julia> flux = randn(size(wave));

julia> spec = Spectrum(wave, flux, name="Echelle")
Spectrum: Echelle
-----------------
Number of orders: 2

```

There is easy integration with ``Unitful`` and its sub-projects
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = collect(range(1e4, 4e4, length=1000))u"angstrom";

julia> sigma = randn(size(wave))u"erg/cm^2/s/angstrom";

julia> flux = sigma .+ 100u"W/m^2/m"; # There will be implicit unit promotion

julia> unit(flux[1])
kg m^-1 s^-3

julia> spec = Spectrum(wave, flux, sigma, name="Unitful")
Spectrum: Unitful
-----------------
Number of orders: 1
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
function Spectrum(wave::AbstractMatrix{T}, flux::AbstractMatrix{F}, σ::AbstractMatrix{S}, mask::AbstractMatrix{Bool}; name::String = "") where {T<:Number, F<:Number, S<:Number}
    orders = [Order(w, f, s, m) for w in wave, f in flux, s in σ, m in mask]
    return Spectrum(orders, name)
end
function Spectrum(wave::AbstractMatrix{T}, flux::AbstractMatrix{F}, σ::AbstractMatrix{S}; name::String = "") where {T<:Number, F<:Number, S<:Number}
    mask = trues(size(wave))
    return Spectrum(wave, flux, σ, mask, name = name)
end

function Spectrum(wave::AbstractMatrix{T}, flux::AbstractMatrix{F}; name::String = "") where {T<:Number, F<:Number, S<:Number}
    σ = ones(eltype(flux), size(flux))
    return Spectrum(wave, flux, σ, name = name)
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
    σ(::Spectrum)

Returns the masked σ
"""
function σ(spec::Spectrum)
    return spec.σ[spec.mask]
end
 
function Base.show(io::IO, spec::Spectrum)
    println(io, "Spectrum: $(spec.name)")
    println(io, "-" ^ (length(spec.name) + 10))
    print(io, "Number of orders: $(length(spec.orders))")
end

"""
    ndims(::Spectrum)

Returns the number of dimensions of the Spectrum
"""
Base.ndims(spec::Spectrum) = 2

"""
    size(::Spectrum)

Returns the size, or dimensions, of the Spectrum
"""
Base.size(spec::Spectrum) = (length(spec.orders), length(spec.orders[1]))

"""
    length(::Spectrum)

Returns the length of the Spectrum
"""
Base.length(spec::Spectrum) = length(spec.orders) * length(spec.orders[1])

"""
    getindex(::Spectrum, index::IndexCartesian)

Returns the orders at the given index

# Examples
```jldoctest
julia> spec # from above

julia> spec[1]

julia> typeof(spec[1]) == Order
true

```
"""
Base.getindex(spec::Spectrum, index::IndexCartesian) = spec.orders[index]

