"""
    blackbody(wave::Vector{<:Quantity}, T::Quantity)
    blackbody(wave::Vector{<:Real}, T::Real)

Create a blackbody spectrum using Planck's law. The curve follows the mathematical form

``B_λ(T) = \\frac{2hc^2}{λ^5} \\frac{1}{e^{hc/λ k_B T} - 1}``

If `wave` and `T` are not `Unitful.Quantity`, they are assumed to be in angstrom and Kelvin, and the returned flux will be in units `W m^-2 Å^-1`.

The physical constants are calculated using [PhysicalConstants.jl](https://github.com/juliaphysics/physicalconstants.jl), specifically the CODATA2018 measurement set.

# References
[Planck's Law](https://en.wikipedia.org/wiki/Planck%27s_law)

# Examples
```jldoctest
julia> using Spectra, Unitful, UnitfulAstro

julia> wave = range(1, 3, length=100)u"μm"
(1.0:0.020202020202020204:3.0) μm

julia> bb = blackbody(wave, 2000u"K")
SingleSpectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Float64, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  wave (100,): 1.0 μm .. 3.0 μm
  flux (100,): 89534.30930426194 W μm^-1 m^-2 .. 49010.54557924032 W μm^-1 m^-2
  meta: Dict{Symbol, Any}(:T => 2000 K, :name => "Blackbody")

julia> blackbody(ustrip.(u"angstrom", wave), 6000)
SingleSpectrum(Float64, Float64)
  wave (100,): 10000.0 .. 30000.0
  flux (100,): 1190.9562575755397 .. 40.04325690910415
  meta: Dict{Symbol, Any}(:T => 6000, :name => "Blackbody")

julia> spectral_axis(bb)[argmax(bb)]
1.4444444444444444 μm

julia> 2898u"μm*K" / bb.T # See if it matches up with Wien's law
1.449 μm
```
"""
function blackbody(wave::AbstractVector{<:Quantity}, T::Quantity)
    out_unit = u"W/m^2" / unit(eltype(wave))
    flux = _blackbody(wave, T) .|> out_unit
    return spectrum(wave, flux, name = "Blackbody", T = T)
end

function blackbody(wave::AbstractVector{<:Real}, T::Real)
    flux = ustrip.(u"W/m^2/angstrom", _blackbody(wave * u"angstrom", T * u"K"))
    return spectrum(wave, flux, name = "Blackbody", T = T)
end

_blackbody(wave::AbstractVector{<:Quantity}, T::Quantity) = blackbody(T).(wave)

"""
    blackbody(T::Quantity)

Returns a function for calculating blackbody curves.
"""
blackbody(T::Quantity) = w->2h * c_0^2 / w^5 / (exp(h * c_0 / (w * k_B * T)) - 1)

"""
    equivalent_width(::AbstractSpectrum)

Calculate the equivalent width of the given continuum-normalized spectrum. Return value has units equal to wavelengths.
"""
function equivalent_width(spec::AbstractSpectrum)
    dx = spectral_axis(spec)[end] - spectral_axis(spec)[1]
    flux = ustrip(line_flux(spec))
    return dx - flux * unit(dx)
end

"""
    line_flux(::AbstractSpectrum)

Calculate the line flux of the given continuum-normalized spectrum. Return value has units equal to flux.
"""
function line_flux(spec::AbstractSpectrum)
    avg_dx = diff(spectral_axis(spec))
    return sum(flux_axis(spec)[2:end] .* avg_dx)
end
