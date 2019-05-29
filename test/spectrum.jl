using Unitful, UnitfulAstro

@testset "1D Spectrum" begin
    wave = range(1e4, 5e4, length=1000) |> collect
    sigma = randn(size(wave))
    flux = sigma .+ 100

    spec = Spectrum(wave, flux)

    @test all(spec.mask .== true)
    @test all(spec.σ .== 1)
    @test spec.name == "Spectrum"
    @test size(spec) === (1000,)
    @test length(spec) == 1000

    spec_named = Spectrum(wave, flux, name="test")

    @test spec_named.name == "test"

    spec_sigma = Spectrum(wave, flux, sigma)

    @test spec_sigma.σ == sigma

    mask = sigma .> 0

    spec_mask = Spectrum(wave, flux, sigma, mask, name="masked")

    @test spec_mask.mask == mask
    @test SpecUtils.wave(spec_mask) == wave[mask]
    @test SpecUtils.flux(spec_mask) == flux[mask]
    @test SpecUtils.σ(spec_mask) == sigma[mask]

    flux_trimmed = flux[200:800]
    sigma_trimmed = sigma[100:-1]
    mask_trimmed = mask[1:-50]

    @test_throws AssertionError Spectrum(wave, flux_trimmed)
    @test_throws AssertionError Spectrum(wave, flux, sigma_trimmed)
    @test_throws AssertionError Spectrum(wave, flux, sigma, mask_trimmed)

end

@testset "Unitful Spectrum" begin
    wave = range(1e4, 5e4, length=1000)u"angstrom" |> collect
    sigma = randn(size(wave))u"Jy"
    flux = sigma .+ 100u"Jy"
    
    spec = Spectrum(wave, sigma, flux)

    # Convert to microns
    spec.wave = spec.wave .|> u"μm"
    @test spec.wave ≈ wave
    @test ustrip(spec.wave) ≈ ustrip(wave) ./ 1e4
end
