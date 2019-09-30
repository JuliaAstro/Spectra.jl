@testset "Reddening Av=$Av" for Av = [0.5, 1.0, 2.0]
    # Regression usage
    spec = mock_spectrum()
    spec2 = deepcopy(spec)
    reddened = @inferred redden(spec, Av)
    @inferred redden!(spec2, Av)
    @test reddened.flux ≈ spec2.flux
    @inferred deredden!(spec2, Av)
    @test spec.flux ≈ spec2.flux
    dereddened = @inferred deredden(reddened, Av)
    @test dereddened.flux ≈ spec.flux

    # Custom law
    law(λ, Rv) = sin(Rv * λ) / Rv
    expected = @. spec.flux * 10^(-0.4 * Av * law(spec.wave, π))
    @test expected ≈ redden(spec, Av, law = law, Rv=π).flux
    
    # Bad law
    @test_throws MethodError redden(spec, Av, law = sin)

    # Unitful
    spec = mock_spectrum(use_units=true)
    spec2 = deepcopy(spec)
    reddened = @inferred redden(spec, Av)
    @inferred redden!(spec2, Av)
    @test reddened.flux ≈ spec2.flux
    @inferred deredden!(spec2, Av)
    @test spec.flux ≈ spec2.flux
    dereddened = @inferred deredden(reddened, Av)
    @test dereddened.flux ≈ spec.flux
end

@testset "Reddening Av=0" begin
    # Test no change when Av = 0
    Av = 0.0
    spec = mock_spectrum()
    reddened = redden(spec, Av)
    @test reddened.flux ≈ spec.flux
    dereddened = deredden(reddened, Av)
    @test dereddened.flux ≈ spec.flux
end
