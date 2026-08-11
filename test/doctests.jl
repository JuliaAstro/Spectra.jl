using Documenter: DocMeta, doctest

DocMeta.setdocmeta!(SpectrumBase, :DocTestSetup, :(using SpectrumBase); recursive = true)

doctest(SpectrumBase)
