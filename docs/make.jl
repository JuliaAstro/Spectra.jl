using Documenter
using Spectra

makedocs(
    sitename = "Spectra.jl",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://juliaastro.github.io/Spectra.jl/stable/",
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
    repo = "https://github.com/JuliaAstro/Spectra.jl.git",
)
