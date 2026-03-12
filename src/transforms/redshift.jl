const _c_mps = Float64(ustrip(c_0))

_velocity_ratio(v::Real) = v / _c_mps
_velocity_ratio(v::Quantity) = ustrip(u"m/s", v) / _c_mps

"""
    redshift!(spec::AbstractSpectrum, z::Real)

In-place version of [`redshift`](@ref).
"""
function redshift!(spec::AbstractSpectrum, z::Real)
    spec.spectral_axis = spectral_axis(spec) .* (1 + z)
    return spec
end

"""
    redshift(spec::AbstractSpectrum, z::Real)

Apply a cosmological redshift to a spectrum, returning a new spectrum with shifted wavelengths.

The observed wavelength is related to the rest-frame wavelength by

``λ_\\mathrm{obs} = λ_\\mathrm{rest} \\cdot (1 + z)``

where `z` is the cosmological redshift parameter. Only the spectral axis is transformed;
flux density values are not corrected for the stretching of the wavelength bins.

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
function redshift(spec::AbstractSpectrum, z::Real)
    shifted = deepcopy(spec)
    redshift!(shifted, z)
    return shifted
end

"""
    doppler_shift!(spec::AbstractSpectrum, v; relativistic=false)

In-place version of [`doppler_shift`](@ref).
"""
function doppler_shift!(spec::AbstractSpectrum, v; relativistic::Bool = false)
    β = _velocity_ratio(v)
    if relativistic
        spec.spectral_axis = spectral_axis(spec) .* sqrt((1 + β) / (1 - β))
    else
        spec.spectral_axis = spectral_axis(spec) .* (1 + β)
    end
    return spec
end

"""
    doppler_shift(spec::AbstractSpectrum, v; relativistic=false)

Apply a Doppler shift to a spectrum, returning a new spectrum with shifted wavelengths.

**Non-relativistic** (default):

``λ_\\mathrm{obs} = λ_\\mathrm{rest} \\cdot \\left(1 + \\frac{v}{c}\\right)``

**Relativistic** (`relativistic=true`):

``λ_\\mathrm{obs} = λ_\\mathrm{rest} \\cdot \\sqrt{\\frac{1 + v/c}{1 - v/c}}``

Only the spectral axis is transformed; flux density values are preserved as-is.

# Arguments
- `spec`: The input spectrum.
- `v`: Radial velocity. A `Unitful.Quantity` with velocity dimensions is automatically
  converted using the speed of light in vacuum. A plain `Real` is interpreted as m/s.
- `relativistic`: If `true`, use the relativistic Doppler formula. Default is `false`.

# Examples
```jldoctest
julia> spec = spectrum(collect(4000.0:1000.0:8000.0), ones(5));

julia> v = 1000.0;  # 1000 m/s

julia> shifted = doppler_shift(spec, v);

julia> spectral_axis(shifted) ≈ spectral_axis(spec) .* (1 + v / 299792458.0)
true
```

See also [`redshift`](@ref) for cosmological redshift.
"""
function doppler_shift(spec::AbstractSpectrum, v; relativistic::Bool = false)
    shifted = deepcopy(spec)
    doppler_shift!(shifted, v; relativistic)
    return shifted
end
