#@testset "Continuum" begin
#    spec = spectrum([1, 2, 3.], [1, -10, 1.])
#    spec_cont = continuum(spec)
#
#    @test spectral_axis(spec_cont) == spectral_axis(spec)
#    @test flux_axis(spec_cont) ≈ ones(eltype(flux_axis(spec)), length(flux_axis(spec)))
#    @test meta(spec_cont)[:coeffs] == meta(spec_cont)[:coeffs] ≈ [-4.5, 0, 5.5, 0]
#    @test meta(spec_cont)[:normalized]
#
#    continuum!(spec)
#    @test spec == spec_cont
#end
