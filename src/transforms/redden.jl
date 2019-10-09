using DustExtinction
import DustExtinction: redden, deredden

export redden,
       redden!,
       deredden,
       deredden!

"""
    redden!(::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)

In-place version of [`redden`](@ref)
"""
function redden!(spec::T, Av; Rv = 3.1, law = ccm89) where {T <: AbstractSpectrum}
    @. spec.flux = redden(spec.flux, spec.wave, Av, Rv = Rv, law = law)
    return spec
end

"""
    redden(::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)

Redden a spectrum using common color laws provided by [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl). `Av` is the total extinction, `Rv` is the selective extinction (3.1 is a common value for the Milky Way) and `law` is the color law to use for determining the extinction. 
"""
function redden(spec::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)
    tmp_spec = deepcopy(spec)
    redden!(tmp_spec, Av, Rv = Rv, law = law)
    return tmp_spec
end

"""
    deredden!(::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)

In-place version of [`deredden`](@ref)
"""
function deredden!(spec::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)
    @. spec.flux = deredden(spec.flux, spec.wave, Av, Rv = Rv, law = law)
    return spec
end

"""
    deredden(::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)

Deredden a spectrum using common color laws provided by [DustExtinction.jl](https://github.com/juliaastro/dustextinction.jl). `Av` is the total extinction, `Rv` is the selective extinction (3.1 is a common value for the Milky Way) and `law` is the color law to use for determining the extinction. 
"""
function deredden(spec::AbstractSpectrum, Av; Rv = 3.1, law = ccm89)
    tmp_spec = deepcopy(spec)
    deredden!(tmp_spec, Av, Rv = Rv, law = law)
    return tmp_spec
end
