#function mock_spectrum(n::Int = Int(1e3); use_units::Bool = false)
#    wave = range(1e4, 3e4, length = n)
#    sigma = 0.1 .* sin.(wave)
#    T = 6700
#    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
#    if use_units
#        wave *= u"angstrom"
#        flux *= u"erg/s/cm^2/angstrom"
#    end
#    spectrum(wave, flux, name="Test Spectrum")
#end
#
#@testset "resample" begin
#    @testset "Resampling" begin
#        spec = mock_spectrum()
#        new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
#        res_spec = resample(spec, new_wave)
#
#        @test res_spec.wave == new_wave
#        @test length(res_spec.flux) == length(new_wave)
#
#        resample!(spec, new_wave)
#        @test res_spec.wave == spec.wave
#        @test res_spec.flux == spec.flux
#
#        # Unitful
#        spec = mock_spectrum(use_units=true)
#        new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
#        @assert unit(eltype(new_wave)) == unit(eltype(spec.wave))
#        res_spec = resample(spec, new_wave)
#
#        @test res_spec.wave == new_wave
#        @test length(res_spec.flux) == length(new_wave)
#
#        resample!(spec, new_wave)
#        @test res_spec.wave == spec.wave
#        @test res_spec.flux == spec.flux
#
#        # Test resampling to another Spectrum
#        spec1 = mock_spectrum(Integer(1e4))
#        spec2 = mock_spectrum(Integer(1e3))
#        res_spec = resample(spec1, spec2)
#        @test res_spec.wave == spec2.wave
#
#        resample!(spec1, spec2)
#        @test spec1.wave == spec2.wave
#        @test spec1.flux == res_spec.flux
#
#        # Unitful
#        spec1 = mock_spectrum(Integer(1e4), use_units=true)
#        spec2 = mock_spectrum(Integer(1e3), use_units=true)
#        res_spec = resample(spec1, spec2)
#
#        @test res_spec.wave == spec2.wave
#        @test unit(eltype(spec1.flux)) == unit(eltype(spec2.flux)) == unit(eltype(res_spec.flux))
#
#        # Test when spectra2 has different units
#        spec1 = mock_spectrum(Integer(1e4), use_units=true)
#        spec2 = mock_spectrum(Integer(1e3), use_units=true)
#        spec1.wave = uconvert.(u"cm", spec1.wave)
#        resample!(spec1, spec2)
#        @test ustrip.(spec1.wave) ≈ ustrip.(unit(eltype(spec1.wave)), spec2.wave)
#
#        # address bug when doing the same thing but affecting spec2
#        spec1 = mock_spectrum(Integer(1e4), use_units=true)
#        spec2 = mock_spectrum(Integer(1e3), use_units=true)
#        spec2.wave = uconvert.(u"cm", spec2.wave)
#        resample!(spec1, spec2)
#        @test ustrip.(spec1.wave) ≈ ustrip.(unit(eltype(spec1.wave)), spec2.wave)
#
#    end
#end
