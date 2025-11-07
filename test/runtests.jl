using ParallelTestRunner: runtests, find_tests, parse_args
import Spectra

const init_code = quote
    using Spectra: Spectra, Spectrum, SingleSpectrum, EchelleSpectrum, IFUSpectrum, spectrum
    using Measurements: Measurements, ±
    using Unitful: @u_str, unit, ustrip
    import Random
end

args = parse_args(Base.ARGS)
testsuite = find_tests(@__DIR__)

runtests(Spectra, args; testsuite, init_code)
