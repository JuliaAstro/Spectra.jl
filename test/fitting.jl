using Spectra: spectrum, continuum, continuum!

@testset "Continuum" begin
    spec = spectrum([1, 2, 3.], [1, -10, 1.])
    spec_cont = continuum(spec)

    @test spec_cont.wave == spec.wave
    @test spec_cont.flux ≈ ones(eltype(spec.flux), length(spec.flux))
    @test spec_cont.meta[:coeffs] == spec_cont.meta[:coeffs] ≈ [-4.5, 0, 5.5, 0]
    @test spec_cont.meta[:normalized]

    continuum!(spec)
    @test spec == spec_cont
end
