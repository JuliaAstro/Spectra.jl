
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
