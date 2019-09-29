using DustExtinction
import DustExtinction: redden, deredden

export redden,
       redden!,
       deredden,
       deredden!

function redden!(spec::AbstractSpectrum, Av; RV = 3.1, law = ccm89)
    @. spec.flux = redden(spec.flux, spec.wave, Av, RV = RV, law = law)
    return spec
end

function redden(spec::AbstractSpectrum, Av; RV = 3.1, law = ccm89)
    tmp_spec = deepcopy(spec)
    redden!(tmp_spec, Av, RV=RV, law=law)
    return tmp_spec
end

function deredden!(spec::AbstractSpectrum, Av; RV = 3.1, law = ccm89)
    @. spec.flux = deredden(spec.flux, spec.wave, Av, RV = RV, law = law)
    return spec
end

function deredden(spec::AbstractSpectrum, Av; RV = 3.1, law = ccm89)
    tmp_spec = deepcopy(spec)
    deredden!(tmp_spec, Av, RV=RV, law=law)
    return tmp_spec
end
