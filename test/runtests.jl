using Test
using Spectra

using Random
using Unitful, UnitfulAstro, Measurements

Random.seed!(8675309)

@testset "Spectra.jl" begin
    include("spectrum.jl")
    include("utils.jl")
    include("transforms/transforms.jl")
    include("plotting.jl")
end
