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

## Redshift

Spectra can be shifted in wavelength via cosmological redshift or Doppler velocity. Both transformations operate only on the spectral axis; flux values are preserved as-is.

**Cosmological redshift** shifts by a dimensionless parameter `z`:

```jldoctest
julia> using SpectrumBase

julia> spec = spectrum(collect(4000.0:1000.0:8000.0), ones(5));

julia> shifted = redshift(spec, 0.5);

julia> spectral_axis(shifted) ≈ spectral_axis(spec) .* 1.5
true
```

**Doppler shift** shifts by a radial velocity `v`. Pass a `Unitful` velocity or a plain number (interpreted as m/s). Set `relativistic=true` for the full relativistic formula:

```jldoctest
julia> using SpectrumBase, Unitful

julia> spec = spectrum(collect(4000.0:1000.0:8000.0), ones(5));

julia> shifted = doppler_shift(spec, 100u"km/s");

julia> shifted_rel = doppler_shift(spec, 100u"km/s"; relativistic=true);
```

Both `redshift` and `doppler_shift` return a new spectrum. In-place variants `redshift!` and `doppler_shift!` are also available.

### API/Reference

```@docs
redshift
redshift!
doppler_shift
doppler_shift!
```

## Resampling

External interpolators, e.g., from [DataInterpolations.jl](https://github.com/SciML/DataInterpolations.jl) or [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl), can be used to resample spectra onto a given wavelength grid. Starting with a sample spectrum `spec`, we first create a [`SpectrumResampler`](@ref) object `resampler` which stores the initial spectrum and interpolator `interp` together. We then apply this object to the wavelength grid of our choice to produce the resampled spectrum. We show example usage in the docstring below:

```@docs
SpectrumResampler
```
