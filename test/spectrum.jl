@testset "Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    flux = sigma .+ 100

    spec = Spectrum(wave, flux)

    @test spec.wave ≈ collect(wave)
    @test all(spec.sigma .≈ 1)
    @test size(spec) === (1000,)
    @test length(spec) == 1000

    spec_sigma = Spectrum(wave, flux, sigma)

    @test spec_sigma.sigma == sigma

    flux_trimmed = flux[200:800]
    sigma_trimmed = sigma[100:-1]

    @test_throws AssertionError Spectrum(wave, flux_trimmed)
    @test_throws AssertionError Spectrum(wave, flux, sigma_trimmed)

end

@testset "Unitful Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)u"angstrom"
    sigma = randn(size(wave))u"W/m^2/angstrom"
    flux = sigma .+ 100u"W/m^2/angstrom"

    spec = Spectrum(wave, sigma, flux)

    @test spec.wave ≈ wave
end

@testset "Arithmetic" begin
    spec = mock_spectrum()

    # Scalars/ vectors
    values = [100, randn(size(spec))]
    for A in values 
        # addition
        s = spec + A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .+ A
        @test s.sigma == spec.sigma

        # subtraction
        s = spec - A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .- A
        @test s.sigma == spec.sigma

        # multiplication
        s = spec * A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .* A
        @test s.sigma == spec.sigma .* abs.(A)

        # division
        s = spec / A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux ./ A
        @test s.sigma == spec.sigma ./ abs.(A)
    end

    spec = mock_spectrum(use_units=true)

    # Scalars/ vectors
    values = [100u"W/m^2/cm", randn(size(spec))u"W/m^2/cm"]
    for A in values 
        # addition
        s = spec + A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .+ A
        @test s.sigma == spec.sigma

        # subtraction
        s = spec - A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .- A
        @test s.sigma == spec.sigma

        # multiplication
        s = spec * A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux .* A
        @test s.sigma == spec.sigma .* abs.(A)

        # division
        s = spec / A
        @test s.wave == spec.wave
        @test s.flux ≈ spec.flux ./ A
        @test s.sigma == spec.sigma ./ abs.(A)
    end
end
