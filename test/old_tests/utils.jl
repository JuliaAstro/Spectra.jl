#using Spectra: blackbody, line_flux, equivalent_width
#
#@testset "Blackbody T=$T" for T in [2000, 4000, 6000]
#    wave = range(1e3, 5e4, length = 1000)
#    b = 2.897771955185172e7
#
#    bb = @inferred blackbody(wave, T)
#    @test typeof(bb) <: Spectra.Spectrum
#    @test bb.T == T
#    @test spectral_axis(bb)[argmax(bb)] ≈ b / T rtol = 0.01
#
#    wave *= u"angstrom"
#    T *= u"K"
#    bb = @inferred blackbody(wave, T)
#    @test typeof(bb) <: Spectra.Spectrum
#    @test unit(bb)[2] == u"W/m^2/angstrom"
#    @test bb.T == T
#    @test spectral_axis(bb)[argmax(bb)] ≈ b * u"angstrom*K" / T rtol = 0.01
#end
#
#@testset "Line flux" begin
#    spec = spectrum([3, 4, 5], [6, 7, 8])
#    @test line_flux(spec) == 15
#end
#
#@testset "Equivalent width" begin
#    spec = spectrum([1, 2, 3], [1, -10, 1])
#    @test equivalent_width(spec) == 11
#end
