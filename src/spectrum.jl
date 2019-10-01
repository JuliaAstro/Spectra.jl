using WCS, Unitful

export spectrum

#--------------------------------------------------------------------------------------

"""
    spectrum(wave::Vector{<:Real}, flux::Vector{<:Real}; kwds...)
    spectrum(wave::Vector{<:Quantity}, flux::Vector{<:Quantity}; kwds...)

Construct a  single dimensional astronomical spectrum. Note that the dimensions of each array must be equal or an error will be thrown.

# Examples
```jldoctest
julia> using Spectra

julia> wave = range(1e4, 4e4, length=1000);

julia> flux = 100 .* ones(size(wave));

julia> spec = spectrum(wave, flux)
Spectrum (1000,)

julia> spec = spectrum(wave, flux, name="Just Noise")
Spectrum (1000,)
  name: Just Noise

julia> spec.name
Just Noise

```

There is easy integration with [Unitful.jl](https://github.com/painterqubits/unitful.jl) and its sub-projects and [Measurements.jl](https://github.com/juliaphysics/measurements.jl)

```jldoctest
julia> using Spectra, Unitful, UnitfulAstro, Measurements

julia> wave = range(1, 4, length=1000)u"μm";

julia> sigma = randn(size(wave));

julia> flux = (100 .± sigma)u"erg/cm^2/s/angstrom";

julia> spec = spectrum(wave, flux)
UnitfulSpectrum (1000,)
  λ (μm) f (erg Å^-1 cm^-2 s^-1)

```
"""
spectrum(wave, flux; kwds...) = spectrum(collect(wave), collect(flux); kwds...)

function spectrum(wave::Vector{<:Real}, flux::Vector{<:Real}; kwds...) 
    @assert size(wave) == size(flux) "wave and flux must have equal size"
    Spectrum(wave, flux, kwds)
end

function spectrum(wave::Vector{<:Quantity}, flux::Vector{<:Quantity}; kwds...)
    @assert size(wave) == size(flux) "wave and flux must have equal size"
    @assert dimension(eltype(wave)) == u"𝐋" "wave not recognized as having dimensions of wavelengths"
    UnitfulSpectrum(wave, flux, kwds)
end

#--------------------------------------------------------------------------------------

abstract type AbstractSpectrum end

function Base.getproperty(spec::T, nm::Symbol) where {T<:AbstractSpectrum}
    if nm in keys(getfield(spec, :meta))
        return getfield(spec, :meta)[nm]
    else
        return getfield(spec, nm)
    end
end

function Base.propertynames(spec::T) where {T<:AbstractSpectrum}
    natural = (:wave, :flux, :meta)
    meta = keys(spec.meta)
    println(natural)
    println(meta)
    return (natural..., meta...)
end

"""
    Spectrum <: AbstractSpectrum

A 1-dimensional spectrum stored as vectors of real numbers. The wavelengths are assumed to be in angstrom.
"""
mutable struct Spectrum <: AbstractSpectrum
    wave::Vector{<:Real}
    flux::Vector{<:Real}
    meta::Dict
end


function Base.show(io::IO, spec::Spectrum)
    print(io, "Spectrum $(size(spec))")
    for (key, val) in spec.meta
        print(io, "\n  $key: $val")
    end
end

"""
    size(::AbstractSpectrum)
"""
Base.size(spec::AbstractSpectrum) = size(spec.flux)

"""
    length(::AbstractSpectrum)
"""
Base.length(spec::AbstractSpectrum) = length(spec.flux)

"""
    maximum(::AbstractSpectrum)
"""
Base.maximum(spec::AbstractSpectrum) = maximum(spec.flux)
"""
    minimum(::AbstractSpectrum)
"""
Base.minimum(spec::AbstractSpectrum) = minimum(spec.flux)
"""
    argmax(::AbstractSpectrum)
"""
Base.argmax(spec::AbstractSpectrum) = argmax(spec.flux)
"""
    argmin(::AbstractSpectrum)
"""
Base.argmin(spec::AbstractSpectrum) = argmin(spec.flux)
"""
    findmax(::AbstractSpectrum)
"""
Base.findmax(spec::AbstractSpectrum) = findmax(spec.flux)
"""
    findmin(::AbstractSpectrum)
"""
Base.findmin(spec::AbstractSpectrum) = findmin(spec.flux)



# Arithmetic
Base.:+(s::AbstractSpectrum, A) = spectrum(s.wave, s.flux .+ A; s.meta...)
Base.:*(s::AbstractSpectrum, A) = spectrum(s.wave, s.flux .* A; s.meta...)
Base.:/(s::AbstractSpectrum, A) = spectrum(s.wave, s.flux ./ A; s.meta...)
Base.:-(s::AbstractSpectrum) = spectrum(s.wave, -s.flux; s.meta...)
Base.:-(s::AbstractSpectrum, A) = spectrum(s.wave, s.flux .- A; s.meta...)

#--------------------------------------------------------------------------------------

"""
    UnitfulSpectrum <: AbstractSpectrum

A 1-dimensional spectrum stored as vectors of quantities.
"""
mutable struct UnitfulSpectrum <: AbstractSpectrum
    wave::Vector{<:Quantity}
    flux::Vector{<:Quantity}
    meta::Dict
end

function Base.show(io::IO, spec::UnitfulSpectrum)    
    println(io, "UnitfulSpectrum $(size(spec))")
    wtype, ftype = unit(spec)
    print(io, "  λ ($wtype) f ($ftype)")
    for (key, val) in spec.meta
        print(io, "\n  $key: $val")
    end
end

"""
    Unitful.ustrip(::UnitfulSpectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom")
UnitfulSpectrum (1000,)
  λ (Å) f (W Å^-1 m^-2)

julia> ustrip(spec)
Spectrum (1000,)

```
"""
Unitful.ustrip(spec::UnitfulSpectrum) = Spectrum(ustrip.(spec.wave), ustrip.(spec.flux), spec.meta)

"""
    Unitful.unit(::UnitfulSpectrum)

Get the units of a spectrum. Returns a tuple of the wavelength units and flux/sigma units

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(1000);

julia> spec = spectrum(wave * u"angstrom", flux * u"W/m^2/angstrom");

julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)

```
"""
Unitful.unit(spec::UnitfulSpectrum) = unit(eltype(spec.wave)), unit(eltype(spec.flux))
