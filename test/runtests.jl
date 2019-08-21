using Test
using Spectra

# doctests (before others to isolate dependencies)
using Documenter
doctest(Spectra)

using Random
using Unitful, UnitfulAstro

Random.seed!(8675309)

function mock_spectrum(n::Int = Int(1e3); use_units::Bool = false)
    wave = range(1e4, 3e4, length = n)
    sigma = randn(size(wave))
    T = 6700
    flux = @. 1 / (wave^5 * (exp(1 / (wave * T)) - 1)) + sigma
    if use_units
        wave *= u"angstrom"
        flux *= u"W/m^2/angstrom"
        sigma *= u"W/m^2/angstrom"
    end
    Spectrum(wave, flux, sigma, name="Test Spectrum")
end

include("spectrum.jl")
include("ops.jl")


