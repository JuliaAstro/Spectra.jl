using RecipesBase
import Measurements: value

@testset "Plotting" begin
    wave = range(1e4, 3e4, length = 1000)
    sigma = 0.1 .* sin.(wave)
    T = 6700
    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
    wave *= u"angstrom"
    flux *= u"erg/s/cm^2/angstrom"
    spec = spectrum(wave, flux, name = "Test Spectrum")

    rec = RecipesBase.apply_recipe(Dict{Symbol,Any}(), spec)
    @test getfield(rec[1], 1) == Dict{Symbol,Any}(:yscale => :log, 
        :label => "", 
        :xlabel => "wave (Å)", 
        :ylabel => "flux density (erg Å^-1 cm^-2 s^-1)",
        :seriestype => :path)
    @test rec[1].args == (spec.wave, value.(spec.flux))


    strip_spec = ustrip(spec)

    rec = RecipesBase.apply_recipe(Dict{Symbol,Any}(), strip_spec)
    @test getfield(rec[1], 1) == Dict{Symbol,Any}(:yscale => :log, 
        :label => "", 
        :xlabel => "wave (angstrom)", 
        :ylabel => "flux density",
        :seriestype => :path)
    @test rec[1].args == (strip_spec.wave, value.(strip_spec.flux))
end