using Unitful, UnitfulAstro

include("redden.jl")

## Broadening ops
include("kernels.jl")
using Distributions
using FastConv

function _broaden(flux, kernel::Kernel)
    k = evaluate(kernel)
    broad_flux = convn(flux, k)
end

function broaden(spec::Spectrum, kernel::Kernel)
    w_unit, f_unit = unit(spec)
    s = ustrip(spec)
    broad_flux = _broaden(s.flux, kernel)
    return Spectrum(spec.wave, broad_flux * f_unit, name = spec.name)
end
