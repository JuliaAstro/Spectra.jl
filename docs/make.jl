using Documenter
using Spectra
using Unitful
using Measurements

DocMeta.setdocmeta!(Spectra, :DocTestSetup, :(using Spectra); recursive = true)

makedocs(sitename = "Spectra.jl",
    format = Documenter.HTML(;
        prettyurls = true,
        canonical = "https://juliaastro.org/Spectra/stable/",
    ),
    authors = "Miles Lucas and contributors.",
    linkcheck = !("skiplinks" in ARGS),
    modules = [Spectra],
    pages = [
        "Home" => "index.md",
        "spectrum.md",
        "transforms.md",
        "fitting.md",
        "utils.md",
        "contrib.md",
    ],
    warnonly = [:missing_docs],
    # strict = true,
)

deploydocs(;
    repo = "github.com/JuliaAstro/Spectra.jl.git",
    versions = ["stable" => "v^", "v#.#"] # Restrict to minor releases
)
