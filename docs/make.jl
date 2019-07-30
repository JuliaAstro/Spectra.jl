using Documenter
using Spectra

makedocs(
    sitename = "Spectra.jl",
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://juliaastro.github.io/Spectra.jl/stable/",
    ),
    authors = "Miles Lucas and contributors.",
    linkcheck = !("skiplinks" in ARGS),
    modules = [Spectra],
    pages = [
        "Home" => "index.md",
        "Spectrum" => [
            "spectrum.md"
        ],
    ],
    strict = true,
)

deploydocs(
    repo = "github.com/JuliaAstro/Spectra.jl.git",
)
