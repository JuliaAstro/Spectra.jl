function mock_spectrum(n::Int = Int(1e3); use_units::Bool = false)
    wave = range(1e4, 3e4, length = n)
    sigma = 0.1 .* sin.(wave)
    T = 6700
    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
    if use_units
        wave *= u"angstrom"
        flux *= u"erg/s/cm^2/angstrom"
    end
    spectrum(wave, flux, name="Test Spectrum")
end


include("redden.jl")
