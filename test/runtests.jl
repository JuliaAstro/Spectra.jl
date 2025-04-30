using Test
using Spectra
using DustExtinction

using Random
using Unitful, UnitfulAstro, Measurements
using Aqua

Random.seed!(8675309)

@testset "Spectra.jl" begin
    include("spectrum.jl")
    include("utils.jl")
    include("transforms/transforms.jl")
    include("plotting.jl")

    Aqua.test_all(Spectra)
end
