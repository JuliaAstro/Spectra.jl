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
    f_unit = u"W/m^2/angstrom"
    unitful_spec = Spectrum(spec.wave * u"angstrom", 
                            spec.flux * f_unit, 
                            spec.sigma * f_unit, 
                            name = "Unitful Test Spectrum")
    unitful_extincted = extinct(unitful_spec, 0.3)
    @test unit(eltype(unitful_extincted.flux)) == unit(eltype(unitful_spec.flux))
    @test ustrip(unitful_extincted.flux) ≈ extincted.flux


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

end
