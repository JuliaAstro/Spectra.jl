@testset "Spectral Axis" begin
    # Unitful
    wave = [560, 580, 600]u"nm"
    freq = [535.3436750000001, 516.883548275862, 499.6540966666667]u"THz"

    spec_axis = SpectralAxis(λ=wave)
    @test spec_axis.ν ≈ freq
    @test unit(eltype(spec_axis.ν)) == u"Hz"

    spec_axis = SpectralAxis(ν=freq)
    @test spec_axis.λ ≈ wave
    @test unit(eltype(spec_axis.λ)) == u"m"

    # Test size assertion
    @test_throws AssertionError SpectralAxis(wave, freq[1:end-1])
    @test_throws AssertionError SpectralAxis(wave[1:end-1], freq)
    
    # Test creation with ranges
    wave = (1:1:3)u"μm"
    freq = (1e5:5e4:3e5)u"GHz"

    spec_axis = SpectralAxis(λ = wave)
    @test spec_axis.λ ≈ collect(wave)

    spec_axis = SpectralAxis(ν = freq)
    @test spec_axis.ν ≈ collect(freq)


end