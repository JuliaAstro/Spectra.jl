@testset "Spectrum - Single" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    sigma[7] = 1
    sigma[134] = 0.1
    flux = 100 .± sigma
    flux[7] = 1000 ± 1
    flux[134] = 1 ± 0.1

    spec = spectrum(wave, flux, name = "test spectrum")

    @test spec.wave == wave
    @test size(spec) === (1000,)
    @test length(spec) == 1000
    @test maximum(spec) == 1000 ± 1
    @test minimum(spec) == 1 ± 0.1
    @test argmax(spec) == 7
    @test argmin(spec) == 134
    @test findmax(spec) == (1000 ± 1, 7)
    @test findmin(spec) == (1 ± 0.1, 134)
    @test spec.flux == flux
    @test Measurements.uncertainty.(spec.flux) ≈ sigma

    flux_trimmed = flux[200:800]
    @test_throws AssertionError spectrum(wave, flux_trimmed)
    expected = """
    Spectrum(Float64, Measurement{Float64})
      name: test spectrum"""
    @test sprint(show, spec) == expected
    @test spec.name == "test spectrum"
end

@testset "Spectrum - Echelle" begin
    n_orders = 3
    n_wavs = 1000
    wave_1 = range(1e4, 5e4, length=n_wavs)
    wave = repeat(wave_1, 1, n_orders)
    sigma = randn(size(wave_1))
    sigma[7] = 1
    sigma[134] = 0.1
    flux_1 = 100 .± sigma
    flux_1[7] = 1000 ± 1
    flux_1[134] = 1 ± 0.1
    flux = repeat(flux_1, 1, n_orders)

    spec = spectrum(wave, flux, name = "Test Echelle Spectrum")

    @test spec.wave == wave
    @test size(spec) == (n_wavs, n_orders)
    @test length(spec) == n_orders * n_wavs
    @test maximum(spec) == 1000 ± 1
    @test minimum(spec) == 1 ± 0.1
    @test argmax(spec) == CartesianIndex(7, 1)
    @test argmin(spec) == CartesianIndex(134, 1)
    @test findmax(spec) == (1000 ± 1, CartesianIndex(7, 1))
    @test findmin(spec) == (1 ± 0.1, CartesianIndex(134, 1))
    @test eachcol(Measurements.uncertainty.(spec.flux)) ≈ fill(sigma, n_orders)

    flux_trimmed = flux[200:800, :]
    @test_throws AssertionError spectrum(wave, flux_trimmed)
    expected = """
    EchelleSpectrum(Float64, Measurement{Float64})
      # orders: 1000
      name: Test Echelle Spectrum"""
    @test sprint(show, spec) == expected
    @test spec.name == "Test Echelle Spectrum"
end

@testset "Unitful Spectrum" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    sigma[7] = 1
    sigma[134] = 0.1
    flux = 100 .± sigma
    flux[7] = 1000 ± 1
    flux[134] = 1 ± 0.1

    funit = u"W/m^2/angstrom"
    spec = spectrum(wave * u"angstrom", flux * funit, name = "test")

    @test spec.wave ≈ wave * u"angstrom"

    @test size(spec) === (1000,)
    @test length(spec) == 1000
    @test maximum(spec) == (1000 ± 1) * funit
    @test minimum(spec) == (1 ± 0.1) * funit
    @test argmax(spec) == 7
    @test argmin(spec) == 134
    @test findmax(spec) == ((1000 ± 1) * funit, 7)
    @test findmin(spec) == ((1 ± 0.1) * funit, 134)
    @test spec.name == "test"

    # Test stripping
    w_unit, f_unit = unit(spec)
    @test w_unit == u"angstrom"
    @test f_unit == u"W/m^2/angstrom"

    strip_spec = ustrip(spec)
    @test strip_spec.wave == ustrip.(spec.wave)
    @test strip_spec.flux == ustrip.(spec.flux)
    @test strip_spec.meta == spec.meta
    expected = """
    Spectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(Å,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(Å^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
      name: test"""
    @test sprint(show, spec) == expected
end

@testset "Arithmetic" begin
    wave = range(1e4, 5e4, length = 1000)
    sigma = randn(size(wave))
    flux = 100 .± sigma

    spec = spectrum(wave, flux, name = "test spectrum")

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

    # Other spectra
    spec2 = deepcopy(spec)

    s = spec + spec2
    @test s.wave == spec.wave
    @test s.flux ≈ 2 .* spec.flux
    
    s = spec - spec2
    @test s.wave == spec.wave
    @test s.flux ≈ zeros(size(spec))
    
    s = spec * spec2
    @test s.wave == spec.wave
    @test s.flux ≈ spec.flux.^2
        
    s = spec / spec2
    @test s.wave == spec.wave
    @test s.flux ≈ ones(size(spec))


    spec = spectrum(spec.wave * u"cm", spec.flux * u"W/m^2/cm", name = "test unitfulspectrum")

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
