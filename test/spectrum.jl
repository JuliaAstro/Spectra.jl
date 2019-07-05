using Unitful, UnitfulAstro

@testset "Order" begin
    wave = range(1e4, 5e4, length=1000) |> collect
    sigma = randn(size(wave))
    flux = sigma .+ 100

    order = Order(wave, flux)

    @test all(order.mask)
    @test all(order.σ .== 1)
    @test size(order) === (1000,)
    @test length(order) == 1000
    @test ndims(order) == 1

    # Test unit conversion
    flux_int = Int.(flux)
    @assert eltype(flux_int) != eltype(sigma)
    order_promoted = Order(wave, flux_int, sigma)
    @test eltype(order_promoted.flux) == eltype(order_promoted.sigma)

    order_sigma = Order(wave, flux, sigma)

    @test order_sigma.σ == sigma

    mask = sigma .> 0
    @assert !all(mask) "Mask must have some falses"

    order_mask = Order(wave, flux, sigma, mask)

    @test order_mask.mask == mask
    @test SpecUtils.wave(order_mask) == wave[mask]
    @test SpecUtils.flux(order_mask) == flux[mask]
    @test SpecUtils.σ(order_mask) == sigma[mask]

    flux_trimmed = flux[200:800]
    sigma_trimmed = sigma[100:-1]
    mask_trimmed = mask[1:-50]

    @test_throws AssertionError Order(wave, flux_trimmed)
    @test_throws AssertionError Order(wave, flux, sigma_trimmed)
    @test_throws AssertionError Order(wave, flux, sigma, mask_trimmed)

end

@testset "2D Spectrum" begin
    wave = reshape(range(1e4, 5e4, length=1000), 2, :) |> collect
    sigma = randn(size(wave))
    flux = sigma .+ 100

    # Creation via orders
    orders = [Order(w, f, s) for w in wave, f in flux, s in sigma]

    spec = Spectrum(orders)

    @test size(spec.orders) == (2,)
    @test spec.name == ""
    @test size(spec) === (2, 500)
    @test length(spec) == 1000
    @test ndims(spec) == 2

    spec_sigma = Spectrum(wave, flux, sigma)

    @test spec_sigma.σ == sigma

    mask = sigma .> 0
    @assert !all(mask) "Mask must have some falses"

    spec_mask = Spectrum(wave, flux, sigma, mask, name="masked")

    @test spec_mask.mask == mask
    @test spec_mask.name == "masked"
    @test SpecUtils.wave(spec_mask) == wave[mask]
    @test SpecUtils.flux(spec_mask) == flux[mask]
    @test SpecUtils.σ(spec_mask) == sigma[mask]

    wave_3 = reshape(wave, 2, 2, :)
    flux_3 = reshape(flux, 2, 2, :)

    @test_throws DimensionError Spectrum(wave_3, flux_3)
end

@testset "Unitful Spectrum" begin
    wave = range(1e4, 5e4, length=1000)u"angstrom" |> collect
    sigma = randn(size(wave))u"Jy"
    flux = sigma .+ 100u"Jy"
    
    order = Order(wave, sigma, flux)

    # Convert to microns
    order.wave = order.wave .|> u"μm"
    @test order.wave ≈ wave
    @test ustrip(order.wave) ≈ ustrip(wave) ./ 1e4

    # Test unit promotion
    sigma_ = sigma .|> u"W/m^2/cm"
    flux_ = flux .|> u"Jy/s/cm^2/μm"
    order_promoted = Order(wave, flux_, sigma_)
    @test unit(order_promoted.flux[1]) == unit(order_promoted.sigma[1]) == u"kg*m^-1*s^-3"
end
