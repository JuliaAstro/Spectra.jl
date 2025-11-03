using Spectra: Spectra, AbstractSpectrum, SpectrumResampler, spectrum
using DataInterpolations: LinearInterpolation, ExtrapolationType
using Unitful: @u_str, uconvert
using UnitfulAstro
using Measurements: ±

# TODO: See if it makes sense to have an exported API for resample/resample! even though we are using external interpolators.

function resample(spec, new_wave)
    interp = LinearInterpolation(Spectra.flux(spec), Spectra.wave(spec); extrapolation = ExtrapolationType.Constant)
    resampler = SpectrumResampler(spec, interp)
    return resampler(new_wave)
end

function resample(spec1::AbstractSpectrum, spec2::AbstractSpectrum)
    new_wave = Spectra.wave(spec2)
    return resample(spec1, new_wave)
end

function resample!(spec::AbstractSpectrum, new_wave)
    spec_new = resample(spec, new_wave)
    spec.flux = Spectra.flux(spec_new)
    spec.wave = Spectra.wave(spec_new)
    return spec
end

function resample!(spec1::AbstractSpectrum, spec2::AbstractSpectrum)
    new_wave = Spectra.wave(spec2)
    resample!(spec1, new_wave)
end

function mock_spectrum(n::Int = Int(1e3); use_units::Bool = false)
    wave = range(1e4, 3e4, length = n)
    sigma = 0.1 .* sin.(wave)
    T = 6700
    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
    if use_units
        wave *= u"angstrom"
        flux *= u"erg/s/cm^2/angstrom"
    end
    spectrum(wave, flux; name = "Test Spectrum")
end

@testset "resample" begin
    @testset "Resampling" begin
        spec = mock_spectrum()
        new_wave = range(minimum(spec.wave), maximum(spec.wave); length = Integer(length(spec.wave) ÷ 2.4))
        res_spec = resample(spec, new_wave)

        @test Spectra.wave(res_spec) == new_wave
        @test length(Spectra.flux(res_spec)) == length(new_wave)

        resample!(spec, new_wave)
        @test Spectra.wave(res_spec) == spec.wave
        @test Spectra.flux(res_spec) == spec.flux

        # Unitful
        spec = mock_spectrum(use_units=true)
        new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
        @assert unit(eltype(new_wave)) == unit(eltype(spec.wave))
        res_spec = resample(spec, new_wave)

        @test Spectra.wave(res_spec) == new_wave
        @test length(Spectra.flux(res_spec)) == length(new_wave)

        resample!(spec, new_wave)
        @test Spectra.wave(res_spec) == spec.wave
        @test Spectra.flux(res_spec) == spec.flux

        # Test resampling to another Spectrum
        spec1 = mock_spectrum(Integer(1e4))
        spec2 = mock_spectrum(Integer(1e3))
        res_spec = resample(spec1, spec2)
        @test Spectra.wave(res_spec) == Spectra.wave(spec2)

        resample!(spec1, spec2)
        @test Spectra.wave(spec1) == spec2.wave
        @test Spectra.flux(spec1) == Spectra.flux(res_spec)

        # Unitful
        spec1 = mock_spectrum(Integer(1e4), use_units=true)
        spec2 = mock_spectrum(Integer(1e3), use_units=true)
        res_spec = resample(spec1, spec2)

        @test Spectra.wave(res_spec) == spec2.wave
        @test unit(eltype(Spectra.flux(spec1))) == unit(eltype(Spectra.flux(spec2))) == unit(eltype(Spectra.flux(res_spec)))

        # Test when spectra2 has different units
        spec1 = mock_spectrum(Integer(1e4), use_units=true)
        spec2 = mock_spectrum(Integer(1e3), use_units=true)
        spec1.wave = uconvert.(u"cm", spec1.wave)
        resample!(spec1, spec2)
        @test ustrip.(Spectra.wave(spec1)) ≈ ustrip.(unit(eltype(Spectra.wave(spec1))), Spectra.wave(spec2))

        # address bug when doing the same thing but affecting spec2
        spec1 = mock_spectrum(Integer(1e4), use_units=true)
        spec2 = mock_spectrum(Integer(1e3), use_units=true)
        spec2.wave = uconvert.(u"cm", spec2.wave)
        resample!(spec1, spec2)
        @test ustrip.(Spectra.wave(spec1)) ≈ ustrip.(unit(eltype(Spectra.wave(spec1))), Spectra.wave(spec2))
    end
end
