using Test
using Spectra

using Random
using Unitful, UnitfulAstro, Measurements

Random.seed!(8675309)

function mock_spectrum(n::Int = Int(1e3); use_units::Bool = false)
    wave = range(1e4, 3e4, length = n)
    sigma = randn(size(wave))
    T = 6700
    flux = @. 1 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
    if use_units
        wave *= u"angstrom"
        flux *= u"erg/s/cm^2/angstrom"
    end
    Spectrum(wave, flux, name="Test Spectrum")
end

include("spectrum.jl")
# include("ops.jl")


