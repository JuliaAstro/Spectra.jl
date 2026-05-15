using ParallelTestRunner: runtests, find_tests, parse_args
import SpectrumBase

const init_code = quote
    using SpectrumBase: SpectrumBase, Spectrum, SingleSpectrum, EchelleSpectrum, IFUSpectrum, spectrum, spectral_axis, flux_axis
    using Measurements: Measurements, ±
    using Unitful: @u_str, unit, ustrip
    import Random
end

args = parse_args(Base.ARGS)
testsuite = find_tests(@__DIR__)

runtests(SpectrumBase, args; testsuite, init_code)
