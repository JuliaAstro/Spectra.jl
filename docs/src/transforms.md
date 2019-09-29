# Transformations

The following operations and transformations are provided to work on `Spectra`

## Extinction

By levaraging [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) we can apply common reddening laws to our spectra.

```jldoctest
julia> using Unitful, Measurements

julia> wave = (1:0.5:3)u"μm"
(1.0:0.5:3.0) μm

julia> sigma = randn(size(wave))
5-element Array{Float64,1}:
 -1.1801017658060196 
 -1.9975816223291203 
 -0.29087262313445955
  0.05366178453504935
 -0.9024156296738536

julia> flux = (100 .± sigma)u"W/m^2/μm"
5-element Array{Quantity{Measurement{Float64},𝐌*𝐋^-1*𝐓^-3,Unitful.FreeUnits{(μm^-1, m^-2, W),𝐌*𝐋^-1*𝐓^-3,nothing}},1}:
  100.0 ± -1.2 W μm^-1 m^-2
  100.0 ± -2.0 W μm^-1 m^-2
 100.0 ± -0.29 W μm^-1 m^-2
 100.0 ± 0.054 W μm^-1 m^-2
  100.0 ± -0.9 W μm^-1 m^-2

julia> spec = spectrum(wave, flux)
UnitfulSpectrum (5,)
  λ (μm) f (W μm^-1 m^-2)

julia> red = redden(spec, 0.3)
UnitfulSpectrum (5,)
  λ (μm) f (W μm^-1 m^-2)

julia> red.flux
5-element Array{Quantity{Measurement{Float64},𝐌*𝐋^-1*𝐓^-3,Unitful.FreeUnits{(μm^-1, m^-2, W),𝐌*𝐋^-1*𝐓^-3,nothing}},1}:
     89.4 ± 1.1 W μm^-1 m^-2
     94.4 ± 1.9 W μm^-1 m^-2
   96.41 ± 0.28 W μm^-1 m^-2
 97.479 ± 0.052 W μm^-1 m^-2
   98.11 ± 0.89 W μm^-1 m^-2

julia> deredden!(red, 0.3)
UnitfulSpectrum (5,)
  λ (μm) f (W μm^-1 m^-2)

julia> red.flux ≈ spec.flux
true

```

```@docs
redden
redden!
deredden
deredden!
```

