# Dimensionless velocity β ≡ v / c against the speed of light in vacuum.
# A plain number is taken as km/s, the usual unit for radial velocities; the
# `Quantity` methods (which honor the velocity's own units) live in the units
# extensions.
const _SPEED_OF_LIGHT_KMPS = SPEED_OF_LIGHT / 1000
_velocity_ratio(v::Real) = v / _SPEED_OF_LIGHT_KMPS

# Doppler shift
function _doppler_factor(v; relativistic)
    β = _velocity_ratio(v)
    relativistic || return 1 + β
    abs(β) < 1 || throw(DomainError(v, "relativistic Doppler shift requires |v| < c"))
    return sqrt((1 + β) / (1 - β))
end

# Resolve the (1 + z) stretch factor to the scalar actually multiplied onto a
# spectrum's spectral axis. A unitless axis is assumed to be a wavelength
# (stretches). The dimension-aware behavior for `Quantity` axes (wavelength
# stretches, energy compresses) lives in the units extensions: the Unitful
# backend dispatches on the axis element type, while the DynamicQuantities
# backend inspects the axis value (its dimension is not encoded in the type), so
# both hook in through the `spec`-based method below.
_axis_factor(::Type{<:Real}, factor) = factor
# Dispatch on the spectral-axis element type parameter `S` (known at compile time)
# rather than the runtime axis value, so the factor's type stays inferable. The
# DynamicQuantities extension, whose element type does not carry its dimension,
# instead specializes the more-specific `AbstractSpectrum{<:AbstractQuantity}`
# method and resolves the factor from the value.
_axis_factor(spec::AbstractSpectrum{S}, factor) where {S} = _axis_factor(S, factor)

# Return a copy of `spec` whose spectral axis is scaled by `factor`. Rebuilding
# through the constructor (rather than reassigning the field) lets the element
# type promote, e.g., an integer axis becomes floating point, and re-runs the
# `Spectrum` invariant checks. `R` and the type assertions recover the inference
# that is otherwise lost through the `getproperty` overload. `R` is derived with
# `promote_op` rather than `oneunit(S)`, since a DynamicQuantities element type
# does not carry its dimension in the type and so has no `oneunit(::Type)`.
function _scale_spectral_axis(spec::Spectrum{S, F, M, N}, factor) where {S, F, M, N}
    f = _axis_factor(spec, factor)
    R = Base.promote_op(*, S, typeof(f))
    axis = (spectral_axis(spec) .* f)::AbstractArray{R, M}
    flux = copy(flux_axis(spec))::AbstractArray{F, N}
    return Spectrum(axis, flux, deepcopy(meta(spec)))
end

"""
    redshift!(spec::AbstractSpectrum, z::Real)

In-place version of [`redshift`](@ref).

Reassigns the spectral axis, so the element type cannot change.
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

Reassigns the spectral axis, so the element type cannot change. Use [`doppler_shift`](@ref)
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
