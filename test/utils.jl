@testset "Blackbody T=$T" for T in [2000, 4000, 6000]
    wave = range(1e3, 5e4, length = 1000)
    b = 2.897771955185172e7
    
    bb = @inferred blackbody(wave, T)
    @test typeof(bb) == Spectra.Spectrum
    @test bb.T == T
    @test bb.wave[argmax(bb)] ≈ b / T rtol = 0.01

    wave *= u"angstrom"
    T *= u"K"
    bb = @inferred blackbody(wave, T)
    @test typeof(bb) == Spectra.UnitfulSpectrum
    @test unit(bb)[2] == u"W/m^2/angstrom"
    @test bb.T == T
    @test bb.wave[argmax(bb)] ≈ b * u"angstrom*K" / T rtol = 0.01
end
