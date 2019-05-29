using Documenter
using SpecUtils

makedocs(
    sitename = "SpecUtils",
    format = :html,
    modules = [SpecUtils]
)

deploydocs(
    repo = "github.com/mileslucas/SpecUtils.jl.git",
)
