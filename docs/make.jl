using Documenter
using SpecUtils

makedocs(
    sitename = "SpecUtils.jl",
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://mileslucas.com/SpecUtils.jl/stable/",
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
    repo = "github.com/mileslucas/SpecUtils.jl.git",
)
