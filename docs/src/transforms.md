```@meta
DocTestSetup = quote
  using Spectra, Random
  Random.seed!(11894)
end
```

# Transformations

## Extinction

By levaraging [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) we can apply common reddening laws to our spectra.

```jldoctest
julia> using Unitful, Measurements, Random

julia> rng = Random.seed!(0);

julia> wave = (1:0.5:3)u"μm"
(1.0:0.5:3.0) μm

julia> sigma = randn(rng, size(wave))
5-element Vector{Float64}:
  0.942970533446119
  0.13392275765318448
  1.5250689085124804
  0.12390123120559722
 -1.205772284259936

julia> flux = (100 .± sigma)u"W/m^2/μm"
5-element Vector{Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}}}:
 100.0 ± 0.94 W μm^-1 m^-2
 100.0 ± 0.13 W μm^-1 m^-2
 100.0 ± 1.5 W μm^-1 m^-2
 100.0 ± 0.12 W μm^-1 m^-2
 100.0 ± -1.2 W μm^-1 m^-2

julia> spec = spectrum(wave, flux)
Spectrum(Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Unitful.Quantity{Measurements.Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> red = redden(spec, 0.3)
Spectrum(Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Unitful.Quantity{Measurements.Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> red.flux
5-element Vector{Unitful.Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}}}:
 89.44 ± 0.52 W μm^-1 m^-2
   94.4 ± 1.1 W μm^-1 m^-2
 96.41 ± 0.12 W μm^-1 m^-2
 97.48 ± 0.77 W μm^-1 m^-2
 98.11 ± 0.19 W μm^-1 m^-2

julia> deredden!(red, 0.3)
Spectrum(Unitful.Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Unitful.Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> red.flux ≈ spec.flux
true
```

### API/Reference

```@docs
redden
redden!
deredden
deredden!
```

```@meta
DocTestSetup = nothing
```
