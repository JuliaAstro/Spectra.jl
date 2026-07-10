module SpectrumBaseUnitfulExt

using SpectrumBase
using SpectrumBase: AbstractSpectrum, Spectrum, spectrum, spectral_axis, flux_axis, meta, blackbody
import SpectrumBase: _ustrip, _velocity_ratio, _axis_factor
using Unitful: Unitful, @u_str, ustrip, unit, dimension, Quantity, Length, Energy, NoUnits

# Unit-ful physical constants, rebuilt from the SI floats that live in
# `SpectrumBase` so the Unitful backend agrees with the numeric core to the last
# digit.
const h = SpectrumBase.PLANCK_CONSTANT * u"J*s"
const c_0 = SpectrumBase.SPEED_OF_LIGHT * u"m/s"
const k_B = SpectrumBase.BOLTZMANN_CONSTANT * u"J/K"

# Wavelength (𝐋) or energy (𝐋²𝐌𝐓⁻²) — the only spectral axes we accept.
const _WAVELENGTH_OR_ENERGY = (u"𝐋", u"𝐋^2 * 𝐌 * 𝐓^-2")

# --- units-agnostic hooks from the core -------------------------------------

_ustrip(x::Quantity) = ustrip(x)

_velocity_ratio(v::Quantity) = ustrip(NoUnits, v / c_0)

_axis_factor(::Type{<:Length}, factor) = factor          # Wavelength: stretches
_axis_factor(::Type{<:Energy}, factor) = inv(factor)     # Energy: compresses
_axis_factor(::Type{S}, factor) where {S <: Quantity} =
    throw(ArgumentError("cannot shift a spectral axis with dimension $(dimension(S)); expected a wavelength or energy"))

# --- spectrum constructors for Unitful axes ---------------------------------

function SpectrumBase.spectrum(spectral_axis::AbstractVector{<:Quantity}, flux_axis::AbstractVector{<:Quantity}; kwds...)
    @assert dimension(eltype(spectral_axis)) ∈ _WAVELENGTH_OR_ENERGY "spectral_axis not recognized as having dimensions of wavelength or energy."
    Spectrum(spectral_axis, flux_axis, Dict{Symbol, Any}(kwds))
end

function SpectrumBase.spectrum(spectral_axis::AbstractMatrix{<:Quantity}, flux_axis::AbstractMatrix{<:Quantity}; kwds...)
    @assert dimension(eltype(spectral_axis)) ∈ _WAVELENGTH_OR_ENERGY "spectral_axis not recognized as having dimensions of wavelength or energy."
    Spectrum(spectral_axis, flux_axis, Dict{Symbol, Any}(kwds))
end

# --- ustrip / unit on whole spectra -----------------------------------------

"""
    Unitful.ustrip(::AbstractSpectrum)

Remove the units from a spectrum. Useful for processing spectra in tools that don't play nicely with `Unitful.jl`

# Examples
```jldoctest
julia> using Random

julia> rng = Random.seed!(0)
TaskLocalRNG()

julia> using Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(rng, 1000);

julia> spec = spectrum(wave*u"angstrom", flux*u"W/m^2/angstrom")
SingleSpectrum(Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(Å,), 𝐋, nothing}}, Unitful.Quantity{Float64, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(Å^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  spectral axis (1000,): 10000.0 Å .. 30000.0 Å
  flux axis (1000,): 99999.76809093042 W Å^-1 m^-2 .. 300000.2474309158 W Å^-1 m^-2
  meta: Dict{Symbol, Any}()

julia> ustrip(spec)
SingleSpectrum(Float64, Float64)
  spectral axis (1000,): 10000.0 .. 30000.0
  flux axis (1000,): 99999.76809093042 .. 300000.2474309158
  meta: Dict{Symbol, Any}()
```
"""
Unitful.ustrip(spec::AbstractSpectrum) = spectrum(ustrip.(spectral_axis(spec)), ustrip.(flux_axis(spec)); meta(spec)...)

"""
    Unitful.unit(::AbstractSpectrum)

Get the units of a spectrum. Returns a tuple of the spectral axis units and flux/sigma units

# Examples
```jldoctest
julia> using Random

julia> rng = Random.seed!(0)
TaskLocalRNG()

julia> using Unitful, UnitfulAstro

julia> wave = range(1e4, 3e4, length=1000);

julia> flux = wave .* 10 .+ randn(rng, 1000);

julia> spec = spectrum(wave * u"angstrom", flux * u"W/m^2/angstrom");

julia> w_unit, f_unit = unit(spec)
(Å, W Å^-1 m^-2)
```
"""
Unitful.unit(spec::AbstractSpectrum) = unit(eltype(spectral_axis(spec))), unit(eltype(flux_axis(spec)))

# --- blackbody with Unitful arguments ---------------------------------------

function SpectrumBase.blackbody(wave::AbstractVector{<:Quantity}, T::Quantity)
    out_unit = u"W/m^2" / unit(eltype(wave))
    flux = _blackbody(wave, T) .|> out_unit
    return spectrum(wave, flux, name = "Blackbody", T = T)
end

"""
    blackbody(T::Unitful.Quantity)

Returns a function for calculating blackbody curves.
"""
SpectrumBase.blackbody(T::Quantity) = w -> 2h * c_0^2 / w^5 / (exp(h * c_0 / (w * k_B * T)) - 1)

_blackbody(wave::AbstractVector{<:Quantity}, T::Quantity) = SpectrumBase.blackbody(T).(wave)

end # module
