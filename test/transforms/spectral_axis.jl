using SpectrumBase: to_frequency, to_wavelength, redshift
using PhysicalConstants.CODATA2018: c_0
using Unitful: uconvert
using UnitfulAstro

@testset "Wavelength and frequency conversion" begin
    wavelength = [1.0, 1.5, 2.0]u"μm"
    flux = [1.0, 2.0, 3.0]u"Jy"
    spec = spectrum(wavelength, flux, name = "example")

    frequency_spec = to_frequency(spec; unit = u"THz")
    expected_frequency = uconvert.(u"THz", c_0 ./ wavelength)

    @test spectral_axis(frequency_spec) ≈ expected_frequency
    @test flux_axis(frequency_spec) == flux
    @test frequency_spec.name == "example"
    @test spectral_axis(spec) == wavelength

    wavelength_spec = to_wavelength(frequency_spec; unit = u"μm")
    @test spectral_axis(wavelength_spec) ≈ wavelength
    @test flux_axis(wavelength_spec) == flux

    shifted = redshift(frequency_spec, 1.0)
    @test spectral_axis(shifted) ≈ expected_frequency ./ 2

    @test_throws ArgumentError to_frequency(spec; unit = u"μm")
    @test_throws ArgumentError to_wavelength(frequency_spec; unit = u"GHz")
    @test_throws ArgumentError to_frequency(spectrum([1.0, 2.0], [3.0, 4.0]))
end
