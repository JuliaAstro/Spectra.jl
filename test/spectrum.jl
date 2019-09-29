@testset "Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    flux = 100 .± sigma

    spec = spectrum(wave, flux, name="test spectrum")

    @test spec.wave == wave
    @test size(spec) === (1000,)
    @test length(spec) == 1000
    @test spec.flux == flux
    @test Measurements.uncertainty.(spec.flux) ≈ sigma

    flux_trimmed = flux[200:800]
    @test_throws AssertionError spectrum(wave, flux_trimmed)
    expected = """
    Spectrum (1000,)
      name: test spectrum"""
    @test sprint(show, spec) == expected
end

@testset "Unitful Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)u"angstrom"
    sigma = randn(size(wave))
    flux = (100 .± sigma)u"W/m^2/angstrom"

    spec = spectrum(wave, flux, name = "test")

    @test spec.wave ≈ wave

    # Test stripping
    w_unit, f_unit = unit(spec)
    @test w_unit == u"angstrom"
    @test f_unit == u"W/m^2/angstrom"

    strip_spec = ustrip(spec)
    @test strip_spec.wave == ustrip.(spec.wave)
    @test strip_spec.flux == ustrip.(spec.flux)
    @test strip_spec.meta == spec.meta
    expected = """
    UnitfulSpectrum (1000,)
      λ (Å) f (W Å^-1 m^-2)
      name: test"""
    @test sprint(show, spec) == expected
end

@testset "Arithmetic" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    flux = 100 .± sigma

    spec = spectrum(wave, flux, name="test spectrum")

    # Scalars/ vectors
    values = [10, randn(size(spec))]
    for A in values 
        # addition
        s = spec + A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .+ A

        # subtraction
        s = spec - A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .- A

        # multiplication
        s = spec * A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .* A

        # division
        s = spec / A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux ./ A
    end

    spec = spectrum(spec.wave * u"cm", spec.flux * u"W/m^2/cm", name="test unitfulspectrum")

    # Scalars/ vectors
    for A in [10u"W/m^2/cm", randn(size(spec))u"W/m^2/cm"] 
        # addition
        s = spec + A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .+ A

        # subtraction
        s = spec - A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .- A
    end

    for A in [10, randn(size(spec))] 
        # multiplication
        s = spec * A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .* A

        # division
        s = spec / 10
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux ./ 10
    end
end
