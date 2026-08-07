function _reciprocal_axis(spec::Spectrum, target_unit)
    spec isa BinnedSpectrum && throw(ArgumentError("wavelength-frequency conversion is not implemented for binned spectra"))

    axis = Unitful.uconvert.(target_unit, c_0 ./ spectral_axis(spec))
    return Spectrum(axis, copy(flux_axis(spec)), deepcopy(meta(spec)))
end

"""
    to_frequency(spec; unit=u"Hz")

Convert the wavelength axis of a spectrum to frequency using ``ν = c / λ``.
Flux values are preserved.
"""
function to_frequency(spec::Spectrum{S}; unit = u"Hz") where {S <: Unitful.Length}
    dimension(unit) == u"𝐓^-1" || throw(ArgumentError("target unit must have frequency dimensions, got $(dimension(unit))"))
    return _reciprocal_axis(spec, unit)
end

function to_frequency(spec::AbstractSpectrum; unit = u"Hz")
    throw(ArgumentError("to_frequency requires a Unitful wavelength axis"))
end

"""
    to_wavelength(spec; unit=u"m")

Convert the frequency axis of a spectrum to wavelength using ``λ = c / ν``.
Flux values are preserved.
"""
function to_wavelength(spec::Spectrum{S}; unit = u"m") where {S <: Unitful.Frequency}
    dimension(unit) == u"𝐋" || throw(ArgumentError("target unit must have wavelength dimensions, got $(dimension(unit))"))
    return _reciprocal_axis(spec, unit)
end

function to_wavelength(spec::AbstractSpectrum; unit = u"m")
    throw(ArgumentError("to_wavelength requires a Unitful frequency axis"))
end
