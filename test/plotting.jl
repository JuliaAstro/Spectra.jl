using RecipesBase

@testset "Plotting - Single" begin
    wave = range(1e4, 3e4, length = 1000)
    sigma = 0.1 .* sin.(wave)
    T = 6700
    flux = @. 1e14 / (wave^5 * (exp(1 / (wave * T)) - 1)) ± sigma
    wave *= u"angstrom"
    flux *= u"erg/s/cm^2/angstrom"
    spec = spectrum(wave, flux, name = "Test Spectrum")

    rec = RecipesBase.apply_recipe(Dict{Symbol,Any}(), spec)
    @test getfield(rec[1], 1) == Dict{Symbol,Any}(:label => "",
        :xlabel => "wave",
        :ylabel => "flux density",
        :seriestype => :step)
    @test rec[1].args == (ustrip.(spectral_axis(spec)), Measurements.value.(ustrip.(flux_axis(spec))))


    strip_spec = ustrip(spec)

    rec = RecipesBase.apply_recipe(Dict{Symbol,Any}(), strip_spec)
    @test getfield(rec[1], 1) == Dict{Symbol,Any}(:label => "",
        :xlabel => "wave",
        :ylabel => "flux density",
        :seriestype => :step)
    @test rec[1].args == (spectral_axis(strip_spec), Measurements.value.(flux_axis(strip_spec)))
end

@testset "Plotting - Echelle" begin
    n_orders = 10
    wave = reshape(range(100, 1e4, length=1000), 100, n_orders)'
    flux = ones(n_orders, 100) .* collect(1:n_orders)
    spec = spectrum(wave, flux, name = "Test Echelle Spectrum")
    rec  = RecipesBase.apply_recipe(Dict{Symbol,Any}(), spec)
    @test getfield(rec[1], 1) == Dict{Symbol,Any}(
          :label => ["Order $(i)" for i in 1:n_orders],
          :xlabel => "wave",
          :ylabel => "flux density",
          :seriestype => :step,
    )
    @test rec[1].args == (spectral_axis(spec)', flux_axis(spec)')
end
