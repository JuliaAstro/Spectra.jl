# Need to load Spectra into Main to work with ParallelTestRunner
@eval Main using Spectra
using Documenter: DocMeta, doctest

DocMeta.setdocmeta!(Main.Spectra, :DocTestSetup, :(using Spectra); recursive=true)
doctest(Main.Spectra)
