using Documenter
using Spectra

makedocs(
    sitename = "Spectra.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    authors = "Miles Lucas and contributors.",
    linkcheck = !("skiplinks" in ARGS),
    modules = [Spectra],
    pages = [
        "Home" => "index.md",
        "Spectrum" => [
            "spectrum.md",
            "ops.md",
        ],
    ],
    strict = true,
)

deploydocs(
    repo = "github.com/JuliaAstro/Spectra.jl.git",
)
