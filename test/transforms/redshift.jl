using Spectra:
    redshift,
    redshift!,
    doppler_shift,
    doppler_shift!

const C_MPS = 299792458.0

function mock_spectrum_redshift(; use_units::Bool = false)
    wave = collect(range(4000.0, 8000.0, length = 100))
    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * 6700)) - 1))
    if use_units
        wave *= u"angstrom"
        flux *= u"erg/s/cm^2/angstrom"
    end
    spectrum(wave, flux, name = "Test Redshift Spectrum")
end

@testset "redshift" begin
    @testset "Cosmological redshift z=$z" for z in [0.0, 0.1, 0.5, 1.0, 2.0]
        spec = mock_spectrum_redshift()
        original_wave = copy(spectral_axis(spec))
        original_flux = copy(flux_axis(spec))
        original_meta = deepcopy(spec.meta)

        shifted = @inferred redshift(spec, z)

        @test spectral_axis(shifted) ≈ original_wave .* (1 + z)
        @test flux_axis(shifted) ≈ original_flux
        @test shifted.meta == original_meta

        # Original unchanged
        @test spectral_axis(spec) ≈ original_wave
        @test flux_axis(spec) ≈ original_flux
    end

    @testset "Cosmological redshift in-place" begin
        spec = mock_spectrum_redshift()
        expected_wave = spectral_axis(spec) .* 1.5

        result = @inferred redshift!(spec, 0.5)
        @test result === spec
        @test spectral_axis(spec) ≈ expected_wave
    end

    @testset "Cosmological redshift roundtrip" begin
        spec = mock_spectrum_redshift()
        original_wave = copy(spectral_axis(spec))

        shifted = redshift(spec, 1.0)
        unshifted = redshift(shifted, -0.5)
        @test spectral_axis(unshifted) ≈ original_wave
    end

    @testset "Cosmological redshift with Unitful" begin
        spec = mock_spectrum_redshift(use_units = true)
        original_wave = copy(spectral_axis(spec))

        shifted = @inferred redshift(spec, 0.5)
        @test spectral_axis(shifted) ≈ original_wave .* 1.5
        @test flux_axis(shifted) ≈ flux_axis(spec)
    end
end

@testset "doppler_shift" begin
    @testset "Non-relativistic Doppler" begin
        spec = mock_spectrum_redshift()
        original_wave = copy(spectral_axis(spec))
        original_flux = copy(flux_axis(spec))
        original_meta = deepcopy(spec.meta)

        v = 1e5  # 100 km/s in m/s
        shifted = @inferred doppler_shift(spec, v)
        expected = original_wave .* (1 + v / C_MPS)

        @test spectral_axis(shifted) ≈ expected
        @test flux_axis(shifted) ≈ original_flux
        @test shifted.meta == original_meta

        # Original unchanged
        @test spectral_axis(spec) ≈ original_wave
        @test flux_axis(spec) ≈ original_flux
    end

    @testset "Relativistic Doppler" begin
        spec = mock_spectrum_redshift()
        original_wave = copy(spectral_axis(spec))

        v = 1e5  # 100 km/s in m/s
        β = v / C_MPS
        shifted = @inferred doppler_shift(spec, v; relativistic = true)
        expected = original_wave .* sqrt((1 + β) / (1 - β))

        @test spectral_axis(shifted) ≈ expected
    end

    @testset "Non-relativistic ≈ relativistic at low v" begin
        spec = mock_spectrum_redshift()

        v = 100.0  # 100 m/s — very non-relativistic
        nr = doppler_shift(spec, v; relativistic = false)
        rel = doppler_shift(spec, v; relativistic = true)
        @test spectral_axis(nr) ≈ spectral_axis(rel) rtol = 1e-10
    end

    @testset "Doppler in-place" begin
        spec = mock_spectrum_redshift()
        v = 5e4
        expected_wave = spectral_axis(spec) .* (1 + v / C_MPS)

        result = @inferred doppler_shift!(spec, v)
        @test result === spec
        @test spectral_axis(spec) ≈ expected_wave
    end

    @testset "Doppler with Unitful velocity" begin
        spec = mock_spectrum_redshift()
        original_wave = copy(spectral_axis(spec))

        v = 100.0u"km/s"
        shifted = @inferred doppler_shift(spec, v)
        β = 1e5 / C_MPS  # 100 km/s = 1e5 m/s
        expected = original_wave .* (1 + β)
        @test spectral_axis(shifted) ≈ expected

        shifted_rel = @inferred doppler_shift(spec, v; relativistic = true)
        expected_rel = original_wave .* sqrt((1 + β) / (1 - β))
        @test spectral_axis(shifted_rel) ≈ expected_rel
    end

    @testset "Doppler with Unitful spectrum and velocity" begin
        spec = mock_spectrum_redshift(use_units = true)
        original_wave = copy(spectral_axis(spec))

        v = 100.0u"km/s"
        shifted = @inferred doppler_shift(spec, v)
        β = 1e5 / C_MPS
        @test spectral_axis(shifted) ≈ original_wave .* (1 + β)
        @test flux_axis(shifted) ≈ flux_axis(spec)
    end

    @testset "Zero velocity" begin
        spec = mock_spectrum_redshift()
        shifted = doppler_shift(spec, 0.0)
        @test spectral_axis(shifted) ≈ spectral_axis(spec)
        @test flux_axis(shifted) ≈ flux_axis(spec)
    end
end
