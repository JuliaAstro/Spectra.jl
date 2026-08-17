# Dimensionless velocity β ≡ v / c against the speed of light in vacuum.
# A plain number is taken as km/s, the usual unit for radial velocities.
_velocity_ratio(v::Unitful.Quantity) = ustrip(Unitful.NoUnits, v / c_0)
_velocity_ratio(v::Real) = _velocity_ratio(v * u"km/s")

# Doppler shift
function _doppler_factor(v; relativistic)
    β = _velocity_ratio(v)
    relativistic || return 1 + β
    abs(β) < 1 || throw(DomainError(v, "relativistic Doppler shift requires |v| < c"))
    return sqrt((1 + β) / (1 - β))
end

# Resolve the (1 + z) stretch factor to the scalar actually multiplied onto a spectral axis of element type `S`.
_axis_factor(::Type{<:Real}, factor) = factor # Unitless: assume wavelength
_axis_factor(::Type{<:Unitful.Length}, factor) = factor # Wavelength: stretches
_axis_factor(::Type{<:Unitful.Frequency}, factor) = inv(factor) # Frequency: compresses
_axis_factor(::Type{<:Unitful.Energy}, factor) = inv(factor) # Energy: compresses
_axis_factor(::Type{S}, factor) where {S <: Unitful.Quantity} =
    throw(ArgumentError("cannot shift a spectral axis with dimension $(dimension(S)); expected a wavelength, frequency, or energy"))
_axis_factor(spec::AbstractSpectrum, factor) = _axis_factor(eltype(spectral_axis(spec)), factor)

# Return a copy of `spec` whose spectral axis is scaled by `factor`. Rebuilding
# through the constructor (rather than reassigning the field) lets the element
# type promote, e.g., an integer axis becomes floating point, and re-runs the
# `Spectrum` invariant checks. `R` and the type assertions recover the inference
# that is otherwise lost through the `getproperty` overload.
function _scale_spectral_axis(spec::Spectrum{S, F, M, N}, factor) where {S, F, M, N}
    f = _axis_factor(S, factor)
    R = typeof(oneunit(S) * f)
    axis = (spectral_axis(spec) .* f)::AbstractArray{R, M}
    flux = copy(flux_axis(spec))::AbstractArray{F, N}
    return Spectrum(axis, flux, deepcopy(meta(spec)))
end

"""
    redshift!(spec::AbstractSpectrum, z::Real)

In-place version of [`redshift`](@ref).

Reassigns the spectral axis, so its element and array type cannot change.
Use [`redshift`](@ref) for spectra with an integer spectral axis.
"""
function redshift!(spec::AbstractSpectrum, z::Real)
    spec.spectral_axis = spectral_axis(spec) .* _axis_factor(spec, 1 + z)
    return spec
end

@doc raw"""
    redshift(spec::AbstractSpectrum, z::Real)

Apply a cosmological redshift to a spectrum, returning a new spectrum with shifted wavelengths.

The observed wavelength is related to the rest-frame wavelength by:

```math
λ_\mathrm{obs} = λ_\mathrm{rest} (1 + z)\, ,
```

where ``z`` is the cosmological redshift parameter. Only the spectral axis is transformed.
Flux density values are not corrected for the stretching of the wavelength bins.

A wavelength axis is stretched by ``1 + z``. An energy axis (distinguished by its `Unitful` dimension)
is compressed by the same factor. A unitless axis is assumed to be a wavelength.

# Arguments

- `spec`: The input spectrum.
- `z`: Redshift parameter. Positive values redshift (longer wavelengths),
  negative values blueshift (shorter wavelengths).

# Examples

```jldoctest
julia> spec = spectrum(collect(4000.0:1000.0:8000.0), ones(5));

julia> shifted = redshift(spec, 0.1);

julia> spectral_axis(shifted) ≈ spectral_axis(spec) .* 1.1
true
```

See also [`doppler_shift`](@ref) for velocity-based Doppler shifting.
"""
redshift(spec::AbstractSpectrum, z::Real) = _scale_spectral_axis(spec, 1 + z)

"""
    doppler_shift!(spec::AbstractSpectrum, v; relativistic=false)

In-place version of [`doppler_shift`](@ref).

Reassigns the spectral axis, so its element and array type cannot change. Use [`doppler_shift`](@ref)
for spectra with an integer spectral axis.
"""
function doppler_shift!(spec::AbstractSpectrum, v; relativistic = false)
    spec.spectral_axis = spectral_axis(spec) .* _axis_factor(spec, _doppler_factor(v; relativistic))
    return spec
end

@doc raw"""
    doppler_shift(spec::AbstractSpectrum, v; relativistic=false)

Apply a Doppler shift to a spectrum, returning a new spectrum with shifted wavelengths.

**Non-relativistic** (default), the "optical" convention ``\beta \equiv v / c``:

```math
λ_\mathrm{obs} = λ_\mathrm{rest} (1 + \beta)
```

**Relativistic** (`relativistic=true`), equivalent to a cosmological redshift of the same ``z``:

```math
λ_\mathrm{obs} = λ_\mathrm{rest} \sqrt{\frac{1 + \beta}{1 - \beta}}
```

Only the spectral axis is transformed; flux density values are preserved as-is.

# Arguments

- `spec`: The input spectrum.
- `v`: Radial velocity. A `Unitful.Quantity` with velocity dimensions is automatically
  converted using the speed of light in vacuum. A plain `Real` is interpreted as km/s.
- `relativistic`: If `true`, use the relativistic Doppler formula. Default is `false`.

# Examples

```jldoctest
julia> spec = spectrum(collect(4000.0:1000.0:8000.0), ones(5));

julia> v = 1000.0;  # 1000 km/s

julia> shifted = doppler_shift(spec, v);

julia> spectral_axis(shifted) ≈ spectral_axis(spec) .* (1 + v / 299792.458)
true
```

See also [`redshift`](@ref) for cosmological redshift.
"""
doppler_shift(spec::AbstractSpectrum, v; relativistic = false) = _scale_spectral_axis(spec, _doppler_factor(v; relativistic))
