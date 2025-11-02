module Spectra

# common.jl
export AbstractSpectrum, spectrum
# utils.jl
export blackbody
# transforms/redden.jl
export redden, redden!, deredden, deredden!
# resampling: ../ext/DataInterpolationsExt.jl ../ext/Interpolations.jl
export resample

using RecipesBase: @recipe
using Measurements: Measurements, Measurement
using Unitful: Unitful, Quantity, @u_str, ustrip, unit, dimension
using PhysicalConstants.CODATA2018: h, c_0, k_B

# AbstractSpectrum and common functionality
include("common.jl")

# Spectrum types and basic arithmetic
include("spectrum.jl")
include("EchelleSpectrum.jl")

"""
    spectrum(wave, flux; kwds...)

Construct a spectrum given the spectral wavelengths and fluxes. This will automatically dispatch the correct spectrum type given the shape and element type of the given flux. Any keyword arguments will be accessible from the spectrum as properties.

# Examples
```jldoctest
julia> wave = range(1e4, 4e4, length=1000);

julia> flux = 100 .* ones(size(wave));

julia> spec = spectrum(wave, flux)
Spectrum(Float64, Float64)

julia> spec = spectrum(wave, flux, name="Just Noise")
Spectrum(Float64, Float64)
  name: Just Noise

julia> spec.name
"Just Noise"
```

There is easy integration with [Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl)
and its sub-projects and [Measurements.jl](https://github.com/juliaphysics/measurements.jl)

```jldoctest
julia> using Unitful, UnitfulAstro, Measurements

julia> wave = range(1, 4, length=1000)u"μm";

julia> sigma = randn(size(wave));

julia> flux = (100 .± sigma)u"erg/cm^2/s/angstrom";

julia> spec = spectrum(wave, flux)
Spectrum(Quantity{Float64, 𝐋, Unitful.FreeUnits{(μm,), 𝐋, nothing}}, Quantity{Measurement{Float64}, 𝐌 𝐋^-1 𝐓^-3, Unitful.FreeUnits{(Å^-1, erg, cm^-2, s^-1), 𝐌 𝐋^-1 𝐓^-3, nothing}})
```

For a multi-order spectrum, all orders must have the same length, so be sure to pad any ragged orders with NaN.

```jldoctest
julia> wave = reshape(range(100, 1e4, length=1000), 100, 10)';

julia> flux = ones(10, 100) .* collect(1:10);

julia> spec = spectrum(wave, flux)
EchelleSpectrum(Float64, Float64)
  # orders: 10
```
"""
function spectrum(wave::AbstractVector{<:Real}, flux::AbstractVector{<:Real}; kwds...)
    @assert size(wave) == size(flux) "wave and flux must have equal size"
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractVector{<:Quantity}, flux::AbstractVector{<:Quantity}; kwds...)
    @assert size(wave) == size(flux) "wave and flux must have equal size"
    @assert dimension(eltype(wave)) == u"𝐋" "wave not recognized as having dimensions of wavelengths"
    Spectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractMatrix{<:Real}, flux::AbstractMatrix{<:Real}; kwds...)
    @assert size(wave) == size(flux) "wave and flux must have equal size"
    EchelleSpectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

function spectrum(wave::AbstractMatrix{<:Quantity}, flux::AbstractMatrix{<:Quantity}; kwds...)
    @assert size(wave) == size(flux) "wave and flux must have equal size"
    @assert dimension(eltype(wave)) == u"𝐋" "wave not recognized as having dimensions of wavelengths"
    EchelleSpectrum(wave, flux, Dict{Symbol,Any}(kwds))
end

# Stub
"""
    function resample(spec, wave_sampled, interp)

Resample a spectrum onto the given wavelength grid `wave_sampled` using the supplied interpolator `interp`. Currently supports interpolators from the following packages:

    * [DataInterpolations.jl](https://github.com/SciML/DataInterpolations.jl)
    * [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl)

# Examples

```julia-repl
julia> using DataInterpolations

julia> spec = spectrum([2, 4, 12, 16, 20], [1, 3, 7, 6, 20]);

julia> wave_sampled = [1, 5, 9, 13, 14, 17, 21, 22, 23];

 # BYO interpolator
julia> interp = ...

julia> spec_sampled = resample(spec, wave_sampled, interp)
Spectrum(Int64, Float64)
```
"""
function resample(spec, wave_sampled, interp)
    error("""No supported interpolation package loaded. To enable resampling, load one of the supported interpolation packages below:

    * [DataInterpolations.jl](https://github.com/SciML/DataInterpolations.jl)
    * [Interpolations.jl](https://github.com/JuliaMath/Interpolations.jl)

    PRs to add additional interpolation packages are welcome!
    """)
end

"""
    SpectrumResampler(spec::Spectrum, interp)
Type representing the spectrum `spec` with interpolator `interp`.

```jldoctest
julia> using Spectra: spectrum, flux, wave, SpectrumResampler

julia> using DataInterpolations: LinearInterpolation, ExtrapolationType

julia> spec = spectrum([2, 4, 12, 16, 20], [1, 3, 7, 6, 20]);

julia> wave_sampled = [1, 5, 9, 13, 14, 17, 21, 22, 23];

julia> interp = LinearInterpolation(flux(spec), wave(spec); extrapolation = ExtrapolationType.Constant);

julia> resampler = SpectrumResampler(spec, interp);

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
function (spec::SpectrumResampler)(wave_sampled)
    newspec = spectrum(wave_sampled, spec.interp.(wave_sampled); meta = spectrum(spec).meta)
    return SpectrumResampler(newspec, spec.interp)
end
resample(spec::SpectrumResampler, wave_sampled) = spec(wave_sampled)

# tools
include("utils.jl")
include("transforms/transforms.jl")
include("plotting.jl")
include("fitting/fitting.jl")

end # module
