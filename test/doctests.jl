# Need to load Spectra into Main to work with ParallelTestRunner
#@eval Main using Spectra
using SpectrumBase
using Documenter: DocMeta, doctest

DocMeta.setdocmeta!(SpectrumBase, :DocTestSetup, :(using SpectrumBase); recursive = true)
doctest(SpectrumBase)
