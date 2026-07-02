using Documenter
using SpectrumBase
using Unitful
using Measurements

makedocs(sitename = "SpectrumBase.jl",
    format = Documenter.HTML(;
        prettyurls = true,
        canonical = "https://juliaastro.org/SpectrumBase/stable/",
    ),
    authors = "Miles Lucas and contributors.",
    linkcheck = !("skiplinks" in ARGS),
    modules = [SpectrumBase],
    pages = [
        "Home" => "index.md",
        "spectrum.md",
        "transforms.md",
        #"fitting.md",
        #"utils.md",
        "contrib.md",
    ],
    warnonly = [:missing_docs],
    doctest = false,
    # strict = true,
)

deploydocs(;
    repo = "github.com/JuliaAstro/SpectrumBase.jl.git",
    versions = ["stable" => "v^", "v#.#"], # Restrict to minor releases
    push_preview = true,
)
