using Spectra: Spectra, AbstractSpectrum, SpectrumResampler, spectrum, wave, flux
using DataInterpolations: LinearInterpolation, ExtrapolationType
using Unitful: @u_str, uconvert
using UnitfulAstro
using Measurements: ±

# TODO: See if it makes sense to have an exported API for resample/resample! even though we are using external interpolators.

function resample(spec, new_wave)
    interp = LinearInterpolation(flux(spec), wave(spec); extrapolation = ExtrapolationType.Constant)
    resampler = SpectrumResampler(spec, interp)
    return resampler(new_wave)
end

function resample(spec1::AbstractSpectrum, spec2::AbstractSpectrum)
    new_wave = wave(spec2)
    return resample(spec1, new_wave)
end

#function resample!(spec::AbstractSpectrum, new_wave)
#    spec_new = resample(spec, new_wave)
#    spec.flux = flux(spec_new)
#    spec.wave = wave(spec_new)
#    return spec
#end

#function resample!(spec1::AbstractSpectrum, spec2::AbstractSpectrum)
#    new_wave = wave(spec2)
#    resample!(spec1, new_wave)
#end

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

@testset "Resampler" begin
    spec = mock_spectrum()
    interp = LinearInterpolation(flux(spec), wave(spec); extrapolation = ExtrapolationType.Constant)
    resampler = SpectrumResampler(spec, interp)
    expected = """
    SpectrumResampler(Float64, Measurements.Measurement{Float64})
      spec: Spectrum(Float64, Measurements.Measurement{Float64})
      name: Test Spectrum
      interpolator: DataInterpolations.LinearInterpolation{Vector{Measurements.Measurement{Float64}}, Vector{Float64}, Vector{Measurements.Measurement{Float64}}, Vector{Measurements.Measurement{Float64}}, Measurements.Measurement{Float64}}"""

    @test sprint(show, resampler) == expected
    @test wave(resampler) == wave(spec)
    @test flux(resampler) == flux(spec)
end

@testset "Resampling" begin
    spec = mock_spectrum()
    new_wave = range(minimum(spec.wave), maximum(spec.wave); length = Integer(length(spec.wave) ÷ 2.4))
    res_spec = resample(spec, new_wave)
    expected = """
    Spectrum(Float64, Measurements.Measurement{Float64})
      name: Test Spectrum"""

    @test sprint(show, res_spec) == expected
    @test wave(res_spec) == new_wave
    @test length(flux(res_spec)) == length(new_wave)

    #resample!(spec, new_wave)
    #@test wave(res_spec) == spec.wave
    #@test flux(res_spec) == spec.flux

    # Unitful
    spec = mock_spectrum(use_units=true)
    new_wave = range(minimum(spec.wave), maximum(spec.wave), length=Integer(length(spec.wave) ÷ 2.4))
    @assert unit(eltype(new_wave)) == unit(eltype(spec.wave))
    res_spec = resample(spec, new_wave)

    @test wave(res_spec) == new_wave
    @test length(flux(res_spec)) == length(new_wave)

    #resample!(spec, new_wave)
    #@test wave(res_spec) == spec.wave
    #@test flux(res_spec) == spec.flux

    # Test resampling to another Spectrum
    spec1 = mock_spectrum(Integer(1e4))
    spec2 = mock_spectrum(Integer(1e3))
    res_spec = resample(spec1, spec2)
    @test wave(res_spec) == wave(spec2)

    #resample!(spec1, spec2)
    #@test wave(spec1) == spec2.wave
    #@test flux(spec1) == flux(res_spec)

    # Unitful
    spec1 = mock_spectrum(Integer(1e4), use_units=true)
    spec2 = mock_spectrum(Integer(1e3), use_units=true)
    res_spec = resample(spec1, spec2)

    @test wave(res_spec) == spec2.wave
    @test unit(eltype(flux(spec1))) == unit(eltype(flux(spec2))) == unit(eltype(flux(res_spec)))

    # Test when spectra2 has different units
    #spec1 = mock_spectrum(Integer(1e4), use_units=true)
    #spec2 = mock_spectrum(Integer(1e3), use_units=true)
    #spec1.wave = uconvert.(u"cm", spec1.wave)
    #resample!(spec1, spec2)
    #@test ustrip.(wave(spec1)) ≈ ustrip.(unit(eltype(wave(spec1))), wave(spec2))

    # address bug when doing the same thing but affecting spec2
    #spec1 = mock_spectrum(Integer(1e4), use_units=true)
    #spec2 = mock_spectrum(Integer(1e3), use_units=true)
    #spec2.wave = uconvert.(u"cm", spec2.wave)
    #resample!(spec1, spec2)
    #@test ustrip.(wave(spec1)) ≈ ustrip.(unit(eltype(wave(spec1))), wave(spec2))
end
