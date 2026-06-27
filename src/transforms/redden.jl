import DustExtinction

"""
    redden!(::AbstractSpectrum, Av; Rv = 3.1, law = DustExtinction.CCM89)

In-place version of [`redden`](@ref)
"""
function redden!(spec::AbstractSpectrum, Av; Rv = 3.1, law = DustExtinction.CCM89)
    law_instance = DustExtinction.lawinstance(law; Rv)
    DustExtinction.redden!(law_instance, spectral_axis(spec), flux_axis(spec); Av)
    return spec
end

"""
    redden(::AbstractSpectrum, Av; Rv = 3.1, law = DustExtinction.CCM89)

Redden a spectrum using common color laws provided by [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl).
`Av` is the total extinction, `Rv` is the selective extinction (3.1 is a common
value for the Milky Way) and `law` is the color law to use for determining the
extinction.
"""
redden(spec::AbstractSpectrum, Av; kwargs...) = redden!(deepcopy(spec), Av; kwargs...)

"""
    deredden!(::AbstractSpectrum, Av; Rv = 3.1, law = DustExtinction.CCM89)

In-place version of [`deredden`](@ref)
"""
function deredden!(spec::AbstractSpectrum, Av; Rv = 3.1, law = DustExtinction.CCM89)
    law_instance = DustExtinction.lawinstance(law; Rv)
    DustExtinction.deredden!(law_instance, spectral_axis(spec), flux_axis(spec); Av)
    return spec
end

"""
    deredden(::AbstractSpectrum, Av; Rv = 3.1, law = DustExtinction.CCM89)

Deredden a spectrum using common color laws provided by [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl).
`Av` is the total extinction, `Rv` is the selective extinction (3.1 is a common
value for the Milky Way) and `law` is the color law to use for determining the
extinction.
"""
deredden(spec::AbstractSpectrum, Av; kwargs...) = deredden!(deepcopy(spec), Av; kwargs...)
