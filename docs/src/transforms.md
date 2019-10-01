```@meta
DocTestSetup = quote
  using Spectra, Random
  Random.seed!(11894)
end
```

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
 -0.585703503275916  
  1.1359199050439328 
  0.1290826073042479 
 -0.7877421634518855 
 -0.19106542134120702

julia> flux = (100 .± sigma)u"W/m^2/μm"
5-element Array{Quantity{Measurement{Float64},𝐌*𝐋^-1*𝐓^-3,Unitful.FreeUnits{(μm^-1, m^-2, W),𝐌*𝐋^-1*𝐓^-3,nothing}},1}:
 100.0 ± -0.59 W μm^-1 m^-2
   100.0 ± 1.1 W μm^-1 m^-2
  100.0 ± 0.13 W μm^-1 m^-2
 100.0 ± -0.79 W μm^-1 m^-2
 100.0 ± -0.19 W μm^-1 m^-2

julia> spec = spectrum(wave, flux)
UnitfulSpectrum (5,)
  λ (μm) f (W μm^-1 m^-2)

julia> red = redden(spec, 0.3)
UnitfulSpectrum (5,)
  λ (μm) f (W μm^-1 m^-2)

julia> red.flux
5-element Array{Quantity{Measurement{Float64},𝐌*𝐋^-1*𝐓^-3,Unitful.FreeUnits{(μm^-1, m^-2, W),𝐌*𝐋^-1*𝐓^-3,nothing}},1}:
 89.44 ± 0.52 W μm^-1 m^-2
   94.4 ± 1.1 W μm^-1 m^-2
 96.41 ± 0.12 W μm^-1 m^-2
 97.48 ± 0.77 W μm^-1 m^-2
 98.11 ± 0.19 W μm^-1 m^-2

julia> deredden!(red, 0.3)
UnitfulSpectrum (5,)
  λ (μm) f (W μm^-1 m^-2)

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
