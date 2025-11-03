"""
    SpectrumResampler(spec::Spectrum, interp)

Type representing the spectrum `spec` with interpolator `interp`.

```jldoctest
julia> using Spectra: spectrum, flux, wave, SpectrumResampler

julia> using DataInterpolations: LinearInterpolation, ExtrapolationType

julia> spec = spectrum([20, 40, 120, 160, 200], [1, 3, 7, 6, 20]);

julia> interp = LinearInterpolation(flux(spec), wave(spec); extrapolation = ExtrapolationType.Constant);

julia> resampler = SpectrumResampler(spec, interp);

julia> wave_sampled = [10, 50, 90, 130, 140, 170, 210, 220, 230];

julia> result = resampler(wave_sampled);

julia> result isa SpectrumResampler
true

julia> wave(result) == wave_sampled
true

julia> flux(result) == interp.(wave_sampled)
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
    s_new = spectrum(wave_sampled, spec_resampled; meta = spectrum(s).meta)
    return SpectrumResampler(s_new, interp)
end

function Base.show(io::IO, s::SpectrumResampler)
    println(io, "SpectrumResampler($(eltype(wave(s))), $(eltype(flux(s))))")
    println(io, "  spec: ", spectrum(s))
    print(io, "  interpolator: ", s.interp)
end
