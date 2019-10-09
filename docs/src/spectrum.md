```@meta
DocTestSetup = quote
  using Spectra, Random
  Random.seed!(11894)
end
```

# Spectrum

Here we will go over the different spectral types and how we use them.

## Types

Spectra are defined as possible subtypes of `AbstractSpectrum`. You can use these directly for construction, or use the catch-all [`spectrum`](@ref) function, which is preferred.

```@docs
Spectra.Spectrum
Spectra.EchelleSpectrum
```

## Constructors

```@docs
Spectra.spectrum
Spectra.blackbody
Spectra.blackbody
```


## Basic operations

For more advanced transformations, see [Transformations](@ref)

| Function                           |
|:-----------------------------------|
| `Base.length(::AbstractSpectrum)`  |
| `Base.size(::AbstractSpectrum)`    |
| `Base.maximum(::AbstractSpectrum)` |
| `Base.minimum(::AbstractSpectrum)` |
| `Base.argmax(::AbstractSpectrum)`  |
| `Base.argmin(::AbstractSpectrum)`  |
| `Base.findmax(::AbstractSpectrum)`  |
| `Base.findmin(::AbstractSpectrum)`  |

### Arithmetic

| Function                           |
|:-----------------------------------|
| `+(::AbstractSpectrum, A)`         |
| `-(::AbstractSpectrum, A)`         |
| `*(::AbstractSpectrum, A)`         |
| `/(::AbstractSpectrum, A)`         |

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

```@meta
DocTestSetup = nothing
```
