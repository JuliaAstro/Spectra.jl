using Unitful
using Measurements: value

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
    law(λ, RV) = sin(RV * λ) / RV
    expected = @. spec.flux * 10^(-0.4 * Av * law(spec.wave, π))
    @test expected ≈ redden(spec, Av, law = law, RV=π).flux
    
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

# @testset "Resampling" begin
#     spec = mock_spectrum()
#     new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
#     res_spec = resample(spec, new_wave)

#     @test res_spec.wave == new_wave
#     @test length(res_spec.flux) == length(new_wave)
    
#     resample!(spec, new_wave)
#     @test res_spec.wave == spec.wave
#     @test res_spec.flux == spec.flux

#     # Unitful
#     spec = mock_spectrum(use_units=true)
#     new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
#     @assert unit(eltype(new_wave)) == unit(eltype(spec.wave))
#     res_spec = resample(spec, new_wave)

#     @test res_spec.wave == new_wave
#     @test length(res_spec.flux) == length(new_wave)

#     resample!(spec, new_wave)
#     @test res_spec.wave == spec.wave
#     @test res_spec.flux == spec.flux

#     # Test resampling to another Spectrum
#     spec1 = mock_spectrum(Integer(1e4))
#     spec2 = mock_spectrum(Integer(1e3))
#     res_spec = resample(spec1, spec2)
#     @test res_spec.wave == spec2.wave

#     resample!(spec1, spec2)
#     @test spec1.wave == spec2.wave
#     @test spec1.flux == res_spec.flux

#     # Unitful
#     spec1 = mock_spectrum(Integer(1e4), use_units=true)
#     spec2 = mock_spectrum(Integer(1e3), use_units=true)
#     res_spec = resample(spec1, spec2)

#     @test res_spec.wave == spec2.wave
#     @test unit(eltype(spec1.flux)) == unit(eltype(spec2.flux)) == unit(eltype(res_spec.flux))

#     # Test when spectra2 has different units
#     spec1 = mock_spectrum(Integer(1e4), use_units=true)
#     spec2 = mock_spectrum(Integer(1e3), use_units=true)
#     spec1.wave = uconvert.(u"cm", spec1.wave)
#     resample!(spec1, spec2)
#     @test ustrip.(spec1.wave) ≈ ustrip.(unit(eltype(spec1.wave)), spec2.wave)

#     # address bug when doing the same thing but affecting spec2
#     spec1 = mock_spectrum(Integer(1e4), use_units=true)
#     spec2 = mock_spectrum(Integer(1e3), use_units=true)
#     spec2.wave = uconvert.(u"cm", spec2.wave)
#     resample!(spec1, spec2)
#     @test ustrip.(spec1.wave) ≈ ustrip.(unit(eltype(spec1.wave)), spec2.wave)

# end

@testset "Broadening" begin
    spec = mock_spectrum()
    
end
