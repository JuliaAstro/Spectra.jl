# Transformations

## Extinction

By leveraging [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) we can apply common reddening laws to our spectra.

```@example
using SpectrumBase, Unitful, Measurements, Random
rng = Random.seed!(0);
wave = (1:0.5:3)u"μm";
sigma = randn(rng, size(wave));
flux = (100 .± sigma)u"W/m^2/μm"
spec = spectrum(wave, flux)
red = redden(spec, 0.3)
flux_axis(red)
deredden!(red, 0.3)
flux_axis(red) ≈ flux_axis(spec)
```

### API/Reference

```@docs
redden
redden!
deredden
deredden!
```

## Resampling

External interpolators, e.g., from [DataInterpolations.jl](https://github.com/SciML/DataInterpolations.jl) or [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl), can be used to resample spectra onto a given wavelength grid. Starting with a sample spectrum `spec`, we first create a [`SpectrumResampler`](@ref) object `resampler` which stores the initial spectrum and interpolator `interp` together. We then apply this object to the wavelength grid of our choice to produce the resampled spectrum. We show example usage in the docstring below:

```@docs
SpectrumResampler
```
