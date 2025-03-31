using Documenter
using Spectra

DocMeta.setdocmeta!(Spectra, :DocTestSetup, :(using Spectra); recursive = true)

makedocs(sitename = "Spectra.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    authors = "Miles Lucas and contributors.",
    linkcheck = !("skiplinks" in ARGS),
    modules = [Spectra],
    pages = [
        "Home" => "index.md",
        "spectrum.md",
        "transforms.md",
        "fitting.md",
        "analysis.md",
        "contrib.md",
    ],
    # strict = true,
)

deploydocs(repo = "github.com/JuliaAstro/Spectra.jl.git")
