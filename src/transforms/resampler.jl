"""
    SpectrumResampler(spec::Spectrum, interp)

Type representing the spectrum `spec` with interpolator `interp`.

Interpolation methods from many packages can be used without issue. Below we show example usage of [DataInterpolations.jl](https://github.com/SciML/DataInterpolations.jl) and [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl).

First, we set up an arbitrary spectrum and a linear interpolator from DataInterpolations.jl:

```jldoctest resampling
julia> using Spectra: spectrum, flux, wave, SpectrumResampler

julia> using DataInterpolations: LinearInterpolation, ExtrapolationType

julia> spec = spectrum([20, 40, 120, 160, 200], [1, 3, 7, 6, 20]);

julia> interp = LinearInterpolation(flux(spec), wave(spec);
           extrapolation = ExtrapolationType.Constant);
```

Now, we construct the `SpectrumResampler` and define the new wavelength grid that we want to resample the original spectrum to:

```jldoctest resampling
julia> resampler = SpectrumResampler(spec, interp);

julia> wave_sampled = [10, 50, 90, 130, 140, 170, 210, 220, 230];
```

To perform the resampling, you call the resampler with the desired wavelength grid.

```jldoctest resampling
julia> result = resampler(wave_sampled);
```

The resampled wavelength and flux can be obtained with the `wave` and `flux` methods.

```jldoctest resampling
julia> result isa SpectrumResampler
true

julia> wave(result) == wave_sampled
true

julia> flux(result) == interp(wave_sampled)
true
```

Use of [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl) follows the same general procedure, but using a different `interp`:

```jldoctest resampling
julia> using Interpolations: linear_interpolation, Flat

julia> interp = linear_interpolation(wave(spec), flux(spec); extrapolation_bc = Flat());

julia> resampler = SpectrumResampler(spec, interp);

julia> result = resampler(wave_sampled);

julia> result isa SpectrumResampler
true

julia> wave(result) == wave_sampled
true

julia> flux(result) == interp(wave_sampled)
true
```
"""
struct SpectrumResampler{A <: Spectrum, B}
    spectrum::A
    interp::B
end

wave(s::SpectrumResampler) = wave(s.spectrum)
flux(s::SpectrumResampler) = flux(s.spectrum)
spectrum(s::SpectrumResampler) = s.spectrum

function (s::SpectrumResampler)(wave_sampled)
    interp = s.interp
    spec_resampled = interp(wave_sampled)
    s_new = Spectrum(wave_sampled, spec_resampled, spectrum(s).meta)
    # s_new = spectrum(wave_sampled, spec_resampled; meta = spectrum(s).meta)
    return SpectrumResampler(s_new, interp)
end

function Base.show(io::IO, s::SpectrumResampler)
    println(io, "SpectrumResampler($(eltype(wave(s))), $(eltype(flux(s))))")
    println(io, "  spec: ", spectrum(s))
    print(io, "  interpolator: ", typeof(s.interp))
end
