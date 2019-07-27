using Test
using Random
using Spectra
using Unitful, UnitfulAstro

Random.seed!(8675309)

function mock_spectrum(n::Int = 1e4, with_units::Bool = false)
    wave = range(1e4, 4e4, length = n)
    sigma = randn(size(wave))
    T = 6700
    flux = @. 1 / (wave^5 * (exp(1 / (wave * T)) - 1)) + sigma
    if with_units
        wave *= u"angstrom"
        flux *= u"W/m^2/angstrom"
        sigma *= u"W/m^2/angstrom"
    end
    Spectrum(wave, flux, sigma, name="Test Spectrum")
end

include("spectrum.jl")
include("ops.jl")
