export Spectrum, unit, ustrip

import Base
import Unitful

mutable struct Spectrum{W <: Number,F <: Number}
    wave::AbstractVector{W}
    flux::AbstractVector{F}
    name::String
    function Spectrum(wave::AbstractVector{W},
            flux::AbstractVector{F},
            name::String) where {W <: Number,F <: Number}
        @assert size(wave) == size(flux) "No ragged orders allowed"
        new{W,F}(wave, flux, name)
    end
end

"""
    Spectrum(wave, flux; name="")

A signle dimensional astronomical spectrum. If no sigma are provided, they are assumed to be unity. The name is an optional identifier for the Spectrum. Note that the dimensions of each array must be equal or an error will be thrown.

# Examples
```jldoctest
julia> using Spectra

julia> wave = range(1e4, 4e4, length=1000);

julia> flux = randn(size(wave));

julia> spec = Spectrum(wave, flux)
Spectrum:

julia> spec = Spectrum(wave, flux, name="Just Noise")
Spectrum: Just Noise

```

There is easy integration with `Unitful` and its sub-projects
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1u"μm", 4u"μm", length=1000) .|> u"angstrom";

julia> sigma = randn(size(wave));

julia> flux = (100 .± sigma)u"erg/cm^2/s/angstrom"; # There will be implicit unit promotion

julia> unit(flux[1])
kg m^-1 s^-3

julia> spec = Spectrum(wave, flux, name="Unitful")
Spectrum: Unitful
```
"""
function Spectrum(wave::AbstractVector, 
        flux::AbstractVector;
        name::String = "")
   Spectrum(wave, flux, name)
end

function Base.show(io::IO, spec::Spectrum)
    println(io, "Spectrum: $(spec.name)")
    if eltype(spec.wave) <: Quantity
        wtype, ftype = unit(spec)
    else
        wtype = eltype(spec.wave)
        ftype = eltype(spec.flux)
    end
    println(io, "  λ ($wtype) f ($ftype)")
end

"""
    size(::Spectrum)
"""
Base.size(spec::Spectrum) = size(spec.flux)

"""
    length(::Spectrum)
"""
Base.length(spec::Spectrum) = length(spec.flux)


"""
    Unitful.ustrip(::Spectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000) |> collect;

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = Spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom");

julia> strip_spec = ustrip(spec);

```
"""
Unitful.ustrip(spec::Spectrum) = Spectrum(ustrip.(spec.wave), ustrip.(spec.flux), name = spec.name)

"""
    Unitful.unit(::Spectrum)

Get the units of a spectrum. Returns a tuple of the wavelength units and flux/sigma units

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000) |> collect;

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = Spectrum(wave * u"angstrom", flux * u"W/m^2/angstrom");

julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)

```
"""
Unitful.unit(spec::Spectrum) = Tuple(unit.(typeof(spec).parameters))

# Arithmetic
Base.:+(s::Spectrum, A) = Spectrum(s.wave, s.flux .+ A, name = s.name)
Base.:*(s::Spectrum, A) = Spectrum(s.wave, s.flux .* A, name = s.name)
Base.:/(s::Spectrum, A) = Spectrum(s.wave, s.flux ./ A, name = s.name)
Base.:-(s::Spectrum) = Spectrum(s.wave, -s.flux, name=s.name)
Base.:-(s::Spectrum, A) = Spectrum(s.wave, s.flux .- A, name=s.name)


## Plotting
using RecipesBase, Unitful, Measurements

@recipe function f(::Type{Spectrum{W, T}}, spec::Spectrum{W,T}) where {W<:Real, T<:Real}
    seriestype --> :path
    yaxis --> :log
    label --> spec.name
    x := spec.wave
    y := Measurements.value.(spec.flux)
end

@recipe function f(::Type{Spectrum{W, T}}, spec::Spectrum{W, T}) where {W <: Quantity, T<: Quantity}
    seriestype --> :path
    yaxis --> :log
    xunit, yunit = unit(spec)
    xlabel --> string(xunit)
    ylabel --> string(yunit)
    label --> spec.name
    x := spec.wave
    y := Measurements.value.(spec.flux)
end