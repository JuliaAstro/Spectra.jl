using Documenter
using Spectra

makedocs(
    sitename = "Spectra.jl",
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://mileslucas.com/Spectra.jl/stable/",
    ),
    authors = "Miles Lucas and contributors.",
    linkcheck = !("skiplinks" in ARGS),
    modules = [SpecUtils],
    pages = [
        "Home" => "index.md",
        "Spectrum" => [
            "spectrum.md"
        ],
    ],
    strict = true,
)

deploydocs(
    repo = "github.com/mileslucas/Spectra.jl.git",
)
