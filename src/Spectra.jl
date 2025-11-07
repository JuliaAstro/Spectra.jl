module Spectra

# Uniform API
export AbstractSpectrum, spectrum
# spectra_single.jl, spectra_ifu.jl, spectra_echelle.jl
export SingleSpectrum, IFUSpectrum, EchelleSpectrum
# utils.jl
export blackbody, line_flux, equivalent_width
# fitting/fitting.jl
export continuum, continuum!
# transforms/redden.jl
export redden, redden!, deredden, deredden!

using RecipesBase: @recipe
using Measurements: Measurements, Measurement
using Unitful: Unitful, Quantity, @u_str, ustrip, unit, dimension
using PhysicalConstants.CODATA2018: h, c_0, k_B

"""
    AbstractSpectrum{W<:Number, F<:Number}

An abstract holder for astronomical spectra. All types inheriting from this must have the following fields

- wave::Array{W, N}
- flux::Array{F, N}
- meta::Dict{Symbol, Any}
"""
abstract type AbstractSpectrum{W,F} end

"""
    Spectrum <: AbstractSpectrum

A spectrum or spectra stored as arrays of real numbers. The wavelengths are assumed to be in angstrom.
"""
mutable struct Spectrum{W<:Number, F<:Number, M, N} <: AbstractSpectrum{W, F}
    wave::AbstractArray{W, M}
    flux::AbstractArray{F, N}
    meta::Dict{Symbol,Any}
    function Spectrum{W, F, M, N}(wave, flux, meta) where {W<:Number, F<:Number, M, N}
        # Dimension compatibility check
        size(wave, 1) != size(flux, 1) && throw(ArgumentError(
        """
        Wavelength and flux sizes are incompatible. Currently supported sizes are:

        * SingleSpectrum: wave (M-length vector), flux (M-length vector)
        * EchelleSpectrum: wave (M x N matrix), flux (M x N matrix)
        * IFUSpectrum: wave (M-length vector), flux (M x N x K matrix)

        See the documentation for each spectrum type for more.
        """))

        # Wavelength monoticity check
        w = eachcol(wave)
        !(
            all(issorted, w) ||
            all(x -> issorted(x; rev=true), w)
        ) && throw(ArgumentError(
        "Wavelengths must be strictly increasing or decreasing."
        ))

        return new{W, F, M, N}(wave, flux, meta)
    end
end

function Spectrum(wave, flux, meta)
    Spectrum{eltype(wave), eltype(flux), ndims(wave), ndims(flux)}(wave, flux, meta)
end

# Doesn't seem to be used atp
#Spectrum(wave, flux, meta::Dict{Symbol, Any}) = Spectrum(collect(wave), collect(flux), meta)

"""
    wave(::AbstractSpectrum)

Return the wavelengths of the spectrum.
"""
wave(spec::AbstractSpectrum) = spec.wave

"""
    flux(::AbstractSpectrum)

Return the flux of the spectrum.
"""
flux(spec::AbstractSpectrum) = spec.flux

"""
    meta(::AbstractSpectrum)

Return the meta of the spectrum.
"""
meta(spec::AbstractSpectrum) = spec.meta

function Base.getproperty(spec::AbstractSpectrum, nm::Symbol)
    if nm in keys(getfield(spec, :meta))
        return getfield(spec, :meta)[nm]
    else
        return getfield(spec, nm)
    end
end

function Base.propertynames(spec::AbstractSpectrum)
    natural = (:wave, :flux, :meta)
    m = keys(meta(spec))
    return (natural..., m...)
end

# Collection
Base.argmax(spec::AbstractSpectrum) = argmax(flux(spec))
Base.argmin(spec::AbstractSpectrum) = argmin(flux(spec))
Base.eltype(spec::AbstractSpectrum) = eltype(flux(spec))
Base.findmax(spec::AbstractSpectrum) = findmax(flux(spec))
Base.findmin(spec::AbstractSpectrum) = findmin(flux(spec))
Base.length(spec::AbstractSpectrum) = length(flux(spec))
Base.maximum(spec::AbstractSpectrum) = maximum(flux(spec))
Base.minimum(spec::AbstractSpectrum) = minimum(flux(spec))
Base.size(spec::AbstractSpectrum) = size(flux(spec))
Base.size(spec::AbstractSpectrum, i) = size(flux(spec), i)
function Base.iterate(spec::AbstractSpectrum, state=0)
    state == length(spec) && return nothing
    return spec[begin + state], state + 1
end

# Arithmetic
Base.:(==)(s::AbstractSpectrum, o::AbstractSpectrum) = wave(s) == wave(o) && flux(s) == flux(o) && meta(s) == meta(o)
Base.:+(s::T, A) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .+ A, meta(s))
Base.:*(s::T, A::Union{Real, AbstractVector}) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .* A, meta(s))
Base.:/(s::T, A) where {T <: AbstractSpectrum} = T(wave(s), flux(s) ./ A, meta(s))
Base.:-(s::T) where {T <: AbstractSpectrum} = T(wave(s), -flux(s), meta(s))
Base.:-(s::AbstractSpectrum, A) = s + -A
Base.:-(A, s::AbstractSpectrum) = s - A
Base.:-(s::AbstractSpectrum, o::AbstractSpectrum) = s - o # Satisfy Aqua

# Multi-Spectrum
Base.:+(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .+ flux(o), meta(s))
Base.:*(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .* flux(o), meta(s))
Base.:/(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) ./ flux(o) * unit(s)[2], meta(s))
Base.:-(s::T, o::T) where {T <: AbstractSpectrum} = T(wave(s), flux(s) .- flux(o), meta(s))

"""
    Unitful.ustrip(::AbstractSpectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom")
SingleSpectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(Å,), 𝐋, nothing}}, Quantity{Float64, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(Å^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  wave (1000,): 10000.0 Å .. 30000.0 Å
  flux (1000,): 99999.8952204731 W Å^-1 m^-2 .. 299999.8866277076 W Å^-1 m^-2
  meta: Dict{Symbol, Any}()

julia> ustrip(spec)
SingleSpectrum(Float64, Float64)
  wave (1000,): 10000.0 .. 30000.0
  flux (1000,): 99999.8952204731 .. 299999.8866277076
  meta: Dict{Symbol, Any}()
```
"""
Unitful.ustrip(spec::AbstractSpectrum) = spectrum(ustrip.(wave(spec)), ustrip.(flux(spec)); meta(spec)...)

"""
    Unitful.unit(::AbstractSpectrum)

Get the units of a spectrum. Returns a tuple of the wavelength units and flux/sigma units

# Examples
```jldoctest
julia> using Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = spectrum(wave * u"angstrom", flux * u"W/m^2/angstrom");

julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)
```
"""
Unitful.unit(spec::AbstractSpectrum) = unit(eltype(wave(spec))), unit(eltype(flux(spec)))

# Spectrum types and basic arithmetic
include("spectrum_single.jl")
include("spectrum_ifu.jl")
include("spectrum_echelle.jl")

"""
    spectrum(wave, flux; kwds...)

Construct a spectrum given the spectral wavelengths and fluxes. This will automatically dispatch the correct spectrum type given the shape and element type of the given flux. Any keyword arguments will be accessible from the spectrum as properties.

# Examples
```jldoctest
julia> wave = range(1e4, 4e4, length=1000);

julia> flux = 100 .* ones(size(wave));

julia> spec = spectrum(wave, flux)
SingleSpectrum(Float64, Float64)
  wave (1000,): 10000.0 .. 40000.0
  flux (1000,): 100.0 .. 100.0
  meta: Dict{Symbol, Any}()

julia> spec = spectrum(wave, flux, name="Just Noise")
SingleSpectrum(Float64, Float64)
  wave (1000,): 10000.0 .. 40000.0
  flux (1000,): 100.0 .. 100.0
  meta: Dict{Symbol, Any}(:name => "Just Noise")

julia> spec.name
"Just Noise"
```

There is easy integration with [Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl)
and its sub-projects and [Measurements.jl](https://github.com/juliaphysics/measurements.jl)

```jldoctest
julia> using Unitful, UnitfulAstro, Measurements

julia> wave = range(1, 4, length=1000)u"μm";

julia> sigma = randn(size(wave));

julia> flux = (100 .± sigma)u"erg/cm^2/s/angstrom";

julia> spec = spectrum(wave, flux)
SingleSpectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(Å^-1, erg, cm^-2, s^-1), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  wave (1000,): 1.0 μm .. 4.0 μm
  flux (1000,): 100.0 ± 1.2 erg Å^-1 cm^-2 s^-1 .. 100.0 ± 1.1 erg Å^-1 cm^-2 s^-1
  meta: Dict{Symbol, Any}()
```

For a multi-order spectrum, all orders must have the same length, so be sure to pad any ragged orders with NaN.

```jldoctest
julia> wave = reshape(range(100, 1e4, length=1000), 100, 10)';

julia> flux = ones(10, 100) .* collect(1:10);

julia> spec = spectrum(wave, flux)
EchelleSpectrum(Float64, Float64)
  # orders: 10
  wave (10, 100): 100.0 .. 10000.0
  flux (10, 100): 1.0 .. 10.0
  meta: Dict{Symbol, Any}()
```
"""
function spectrum(wave::AbstractVector{<:Real}, flux::AbstractVector{<:Real}; kwds...)
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractVector{<:Real}, flux::AbstractArray{<:Real, 3}; kwds...)
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractMatrix{<:Real}, flux::AbstractMatrix{<:Real}; kwds...)
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractVector{<:Quantity}, flux::AbstractVector{<:Quantity}; kwds...)
    @assert dimension(eltype(wave)) == u"𝐋" "wave not recognized as having dimensions of wavelengths"
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractMatrix{<:Quantity}, flux::AbstractMatrix{<:Quantity}; kwds...)
    @assert dimension(eltype(wave)) == u"𝐋" "wave not recognized as having dimensions of wavelengths"
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

# tools
include("utils.jl")
include("transforms/transforms.jl")
include("plotting.jl")
include("fitting/fitting.jl")

end # module
