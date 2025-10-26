using Spectra: redden

function mock_spectrum(n::Int = Int(1e3); use_units::Bool = false)
    wave = range(1e4, 3e4, length = n)
    sigma = 0.1 .* sin.(wave)
    T = 6700
    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
    if use_units
        wave *= u"angstrom"
        flux *= u"erg/s/cm^2/angstrom"
    end
    spectrum(wave, flux, name="Test Spectrum")
end

@testset redden begin
    # Custom law
    struct CustomLaw <: DustExtinction.ExtinctionLaw
        Rv::Float64
    end
    (law::CustomLaw)(wave) = sin(law.Rv * wave) / law.Rv

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
        expected = @. spec.flux * 10^(-0.4 * Av * CustomLaw(π)(spec.wave))
        @test expected ≈ redden(spec, Av; law=CustomLaw, Rv=π).flux

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
end
