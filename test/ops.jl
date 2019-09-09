using Unitful

@testset "Extinction" begin
    # Standard usage    
    spec = mock_spectrum()
    extincted = extinct(spec, 0.3)
    spec_copy = deepcopy(spec)
    extinct!(spec_copy, 0.3)
    @test extincted.flux ≈ spec_copy.flux

    # Bad law
    @test_throws MethodError extinct(spec, 0.3, law = sin)

    # Custom law
    law(wave, Rv) = sin(Rv * wave) / Rv
    expected = @. spec.flux * 10^(-0.4 * 0.3 * law(spec.wave, 3.1))
    @test expected ≈ extinct(spec, 0.3, law = law).flux

    # Unitful!
    unitful_spec = mock_spectrum(use_units=true)
    unitful_extincted = extinct(unitful_spec, 0.3)
    @test unit(eltype(unitful_extincted.flux)) == unit(eltype(unitful_spec.flux))
    expected = extinct(ustrip(unitful_spec), 0.3)
    @test ustrip.(unitful_extincted.flux) ≈ expected.flux


end

@testset "Resampling" begin
    spec = mock_spectrum()
    new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
    res_spec = resample(spec, new_wave)

    @test res_spec.wave == new_wave
    @test length(res_spec.flux) == length(new_wave)
    @test length(res_spec.sigma) == length(new_wave)
    
    resample!(spec, new_wave)
    @test res_spec.wave == spec.wave
    @test res_spec.flux == spec.flux
    @test res_spec.sigma == spec.sigma

    # Unitful
    spec = mock_spectrum(use_units=true)
    new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
    @assert unit(eltype(new_wave)) == unit(eltype(spec.wave))
    res_spec = resample(spec, new_wave)

    @test res_spec.wave == new_wave
    @test length(res_spec.flux) == length(new_wave)
    @test length(res_spec.sigma) == length(new_wave)

    resample!(spec, new_wave)
    @test res_spec.wave == spec.wave
    @test res_spec.flux == spec.flux
    @test res_spec.sigma == spec.sigma

    # Test resampling to another Spectrum
    spec1 = mock_spectrum(Integer(1e4))
    spec2 = mock_spectrum(Integer(1e3))
    res_spec = resample(spec1, spec2)
    @test res_spec.wave == spec2.wave

    resample!(spec1, spec2)
    @test spec1.wave == spec2.wave
    @test spec1.flux == res_spec.flux
    @test spec1.sigma == res_spec.sigma

    # Unitful
    spec1 = mock_spectrum(Integer(1e4), use_units=true)
    spec2 = mock_spectrum(Integer(1e3), use_units=true)
    res_spec = resample(spec1, spec2)

    @test res_spec.wave == spec2.wave
    @test unit(eltype(spec1.flux)) == unit(eltype(spec2.flux)) == unit(eltype(res_spec.flux))
    @test unit(eltype(spec1.sigma)) == unit(eltype(spec2.sigma)) == unit(eltype(res_spec.sigma))

    # Test when spectra2 has different units
    spec1 = mock_spectrum(Integer(1e4), use_units=true)
    spec2 = mock_spectrum(Integer(1e3), use_units=true)
    spec1.wave = uconvert.(u"cm", spec1.wave)
    resample!(spec1, spec2)
    @test ustrip.(spec1.wave) ≈ ustrip.(unit(eltype(spec1.wave)), spec2.wave)

    # address bug when doing the same thing but affecting spec2
    spec1 = mock_spectrum(Integer(1e4), use_units=true)
    spec2 = mock_spectrum(Integer(1e3), use_units=true)
    spec2.wave = uconvert.(u"cm", spec2.wave)
    resample!(spec1, spec2)
    @test ustrip.(spec1.wave) ≈ ustrip.(unit(eltype(spec1.wave)), spec2.wave)

end

@testset "Broadening" begin
    spec = mock_spectrum()
    
end
