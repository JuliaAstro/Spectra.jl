# Spectrum

Here we will go over the different spectral types and how we use them.

```@meta
DocTestSetup = quote
  using Spectra, Random
  Random.seed!(11894)
end
```

## Spectra

Spectra are defined as possible subtypes of `AbstractSpectrum`. You can use these directly for construction, or use the catch-all [`spectrum`](@ref) function, which is preferred.

```@docs
spectrum
Spectra.Spectrum
Spectra.UnitfulSpectrum
```


## Basic operations

For more advanced transformations, see [Transformations]

```@docs
Base.length
Base.size
```

The following basic arithmetic is provided

|Function           |
|:------------------|
| `+(::AbstractSpectrum, A)` |
| `-(::AbstractSpectrum, A)` |
| `*(::AbstractSpectrum, A)` |
| `/(::AbstractSpectrum, A)` |

## Unitful helpers

```@docs
Unitful.unit
Unitful.ustrip
```

## Plotting

We provide simple plotting recipes for spectra using [Plots.jl](https://github.com/juliaplots/plots.jl)

```@example
using Plots, Spectra

wave = range(1e3, 4e4, length=100)
flux = @. 1.2e9 / wave^5 * 1 / (exp(35969 / wave) - 1)
spec = spectrum(wave, flux)

plot(spec, yaxis=:identity)
savefig("spec-plot.svg"); nothing # hide
```

![](spec-plot.svg)

## Index

```@index
Pages = ["spectrum.md"]
```
