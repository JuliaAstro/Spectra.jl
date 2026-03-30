# Transformations

## Extinction

By leveraging [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl) we can apply common reddening laws to our spectra.

```jldoctest
julia> using Spectra, Unitful, Measurements, Random

julia> rng = Random.seed!(0);

julia> wave = (1:0.5:3)u"μm";

julia> sigma = randn(rng, size(wave));

julia> flux = (100 .± sigma)u"W/m^2/μm"
5-element Vector{Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}}}:
 100.0 ± 0.94 W μm^-1 m^-2
 100.0 ± 0.13 W μm^-1 m^-2
 100.0 ± 1.5 W μm^-1 m^-2
 100.0 ± 0.12 W μm^-1 m^-2
 100.0 ± -1.2 W μm^-1 m^-2

julia> spec = spectrum(wave, flux)
SingleSpectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  spectral axis (5,): 1.0 μm .. 3.0 μm
  flux axis (5,): 100.0 ± 0.94 W μm^-1 m^-2 .. 100.0 ± -1.2 W μm^-1 m^-2
  meta: Dict{Symbol, Any}()

julia> red = redden(spec, 0.3)
SingleSpectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  spectral axis (5,): 1.0 μm .. 3.0 μm
  flux axis (5,): 89.44 ± 0.84 W μm^-1 m^-2 .. 98.1 ± 1.2 W μm^-1 m^-2
  meta: Dict{Symbol, Any}()

julia> flux_axis(red)
5-element Vector{Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}}}:
 89.44 ± 0.84 W μm^-1 m^-2
 94.35 ± 0.13 W μm^-1 m^-2
  96.4 ± 1.5 W μm^-1 m^-2
 97.48 ± 0.12 W μm^-1 m^-2
  98.1 ± 1.2 W μm^-1 m^-2

julia> deredden!(red, 0.3)
SingleSpectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(μm^-1, m^-2, W), 𝐌 𝐋^-1 𝐓^-3, nothing}})
  spectral axis (5,): 1.0 μm .. 3.0 μm
  flux axis (5,): 100.0 ± 0.94 W μm^-1 m^-2 .. 100.0 ± 1.2 W μm^-1 m^-2
  meta: Dict{Symbol, Any}()

julia> flux_axis(red) ≈ flux_axis(spec)
true
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
julia> using Spectra

julia> spec = spectrum(collect(4000.0:1000.0:8000.0), ones(5));

julia> shifted = redshift(spec, 0.5);

julia> spectral_axis(shifted) ≈ spectral_axis(spec) .* 1.5
true
```

**Doppler shift** shifts by a radial velocity `v`. Pass a `Unitful` velocity or a plain number (interpreted as m/s). Set `relativistic=true` for the full relativistic formula:

```jldoctest
julia> using Spectra, Unitful

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