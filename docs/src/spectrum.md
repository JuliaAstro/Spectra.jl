# Spectrum

Here we will go over the different spectral types and how we use them.

## Types

Spectra are defined as possible subtypes of `AbstractSpectrum`. You can use these directly for construction, or use the catch-all [`spectrum`](@ref) function, which is preferred.

```@docs
Spectra.AbstractSpectrum
Spectra.Spectrum
Spectra.SingleSpectrum
Spectra.EchelleSpectrum
Spectra.IFUSpectrum
```

## Constructors

```@docs
Spectra.spectrum
```


## Basic operations

For more advanced transformations, see [Transformations](@ref)

### Getters
```@docs
Spectra.wave(::AbstractSpectrum)
Spectra.flux(::AbstractSpectrum)
Spectra.meta(::AbstractSpectrum)
```

### Array interface

| Function                           |
|:-----------------------------------|
| `Base.argmax(::AbstractSpectrum)`  |
| `Base.argmin(::AbstractSpectrum)`  |
| `Base.eltype(::AbstractSpectrum)`  |
| `Base.findmax(::AbstractSpectrum)` |
| `Base.findmin(::AbstractSpectrum)` |
| `Base.iterate(::AbstractSpectrum)` |
| `Base.length(::AbstractSpectrum)`  |
| `Base.maximum(::AbstractSpectrum)` |
| `Base.minimum(::AbstractSpectrum)` |
| `Base.size(::AbstractSpectrum)`    |

### Arithmetic

| Function                                            |
|:----------------------------------------------------|
| `+(::AbstractSpectrum, A)`                          |
| `-(::AbstractSpectrum, A)`                          |
| `*(::AbstractSpectrum, A)`                          |
| `/(::AbstractSpectrum, A)`                          |
| `Base.(==)(::AbstractSpectrum, ::AbstractSpectrum)` |

## Unitful helpers

```@docs
Unitful.unit
Unitful.ustrip
```

## Plotting

We provide simple plotting recipes for spectra using [Plots.jl](https://github.com/juliaplots/plots.jl)

```@example
using Plots, Spectra

wave = range(1e3, 5e4, length=100)
spec = blackbody(wave, 2000)

plot(spec)
savefig("spec-plot.svg"); nothing # hide
```

![](spec-plot.svg)

## Index

```@index
Pages = ["spectrum.md"]
```
