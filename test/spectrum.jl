using Unitful, UnitfulAstro

@testset "Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    flux = sigma .+ 100

    spec = Spectrum(wave, flux)

    @test spec.wave ≈ collect(wave)
    @test all(spec.mask)
    @test all(spec.sigma .≈ 1)
    @test size(spec) === (1000,)
    @test length(spec) == 1000
    @test ndims(spec) == 1

    spec_sigma = Spectrum(wave, flux, sigma)

    @test spec_sigma.sigma == sigma

    mask = sigma .> 0
    @assert !all(mask) "Mask must have some falses"

    spec_masked = Spectrum(wave, flux, sigma, mask)

    @test spec_masked.mask == mask
    @test Spectra.wave(spec_masked) == wave[mask]
    @test Spectra.flux(spec_masked) == flux[mask]
    @test Spectra.sigma(spec_masked) == sigma[mask]

    flux_trimmed = flux[200:800]
    sigma_trimmed = sigma[100:-1]
    mask_trimmed = mask[1:-50]

    @test_throws AssertionError Spectrum(wave, flux_trimmed)
    @test_throws AssertionError Spectrum(wave, flux, sigma_trimmed)
    @test_throws AssertionError Spectrum(wave, flux, sigma, mask_trimmed)

end

@testset "Unitful Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)u"angstrom" |> collect
    sigma = randn(size(wave))u"Jy"
    flux = sigma .+ 100u"Jy"

    spec = Spectrum(wave, sigma, flux)

    # Convert to microns
    spec.wave = spec.wave .|> u"μm"
    @test spec.wave ≈ wave
    @test ustrip(spec.wave) ≈ ustrip(wave) ./ 1e4
end
