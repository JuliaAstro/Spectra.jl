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
Spectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> red = redden(spec, 0.3)
Spectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> red.flux
5-element Vector{Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}}}:
 89.44 ± 0.84 W μm^-1 m^-2
 94.35 ± 0.13 W μm^-1 m^-2
  96.4 ± 1.5 W μm^-1 m^-2
 97.48 ± 0.12 W μm^-1 m^-2
  98.1 ± 1.2 W μm^-1 m^-2

julia> deredden!(red, 0.3)
Spectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})

julia> red.flux ≈ spec.flux
true
```

## Resampling

External interpolators, e.g., from [DataInterpolations.jl](https://github.com/SciML/DataInterpolations.jl), [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl), can be used to resample spectra onto a given wavelength grid. Starting with a sample spectrum `spec`, we first create a [`SpectrumResampler`](@ref) object `resampler` which stores the initial spectrum and interpolator `interp` together. We then apply this object to the wavelength grid our our choice to produce our desired resampled spectrum. Below, we show how this may be accomplished using either package.

### DataInterpolations.jl

```@repl resample
using Spectra: SpectrumResampler, spectrum, wave, flux

using DataInterpolations: LinearInterpolation, ExtrapolationType

spec = spectrum([20, 40, 120, 160, 200], [1, 3, 7, 6, 20])

interp = LinearInterpolation(flux(spec), wave(spec); extrapolation = ExtrapolationType.Constant)

resampler = SpectrumResampler(spec, interp)
```

We can now apply `resampler` to our desired wavelength grid `wave_sampled` to produce our resampled spectrum:

```@repl resample
wave_sampled = [10, 50, 90, 130, 140, 170, 210, 220, 230];

spec_resampled = resampler(wave_sampled)
```

Calling this on different wavelength grids uses the same stored interpolator, allowing for efficient resampling. For convenience, the resampled spectrum is returned as another `SpectrumResampler` object, which keeps information about the resampled spectrum and applied interpolator coupled. The resulting interpolated flux and wavelength grid can be retrieved with the `flux` and `wave` getters exported by Spectra.jl, respectively:

```@repl resample
wave(spec_resampled)

flux(spec_resampled)

# Check that this is equivalent to calling the interpolator directly
flux(spec_resampled) == interp(wave_sampled)
```

### Interpolations.jl

For completeness, here is how a similar resampling scheme could be accomplished with Interpolations.jl:

```@repl
using Spectra: SpectrumResampler, spectrum, wave, flux

using Interpolations: linear_interpolation, Flat

spec = spectrum([20, 40, 120, 160, 200], [1, 3, 7, 6, 20])

# Note that `wave` and `flux` are flipped relative to the DataInterpolations.jl example
interp = linear_interpolation(wave(spec), flux(spec); extrapolation_bc = Flat())

resampler = SpectrumResampler(spec, interp)

wave_sampled = [10, 50, 90, 130, 140, 170, 210, 220, 230];

spec_resampled = resampler(wave_sampled)

wave(spec_resampled)

flux(spec_resampled)

# Check that this is equivalent to calling the interpolator directly
flux(spec_resampled) == interp(wave_sampled)
```

See the relevant documentation for the external interpolation package used for more information on what configurations can be passed for your desired `interp` object.

### API/Reference

```@docs
redden
redden!
deredden
deredden!
SpectrumResampler
```

```@meta
DocTestSetup = nothing
```
