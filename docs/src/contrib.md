# [Contributing](@id contrib)

## Extending `AbstractSpectrum`

Most of the code written within this library should work as long as your subtype contains the following fields

- `wave::AbstractArray`
- `flux::AbstractArray`
- `meta::Dict{Symbol, Any}`

Variations of `wave` and `flux` ought to work given the appropriate methods being written.

## Contributing Guidelines

In general, for contributing, use the following guidelines

- Write clean, pragmatic julia code
- New features must come with adequete unit testing and documentation
- Each new feature should bump the package one minor version
- Make sure to cite relevant papers and code where appropriate

If you are interested in contributing, head over to [GitHub](https://github.com/juliaastro/spectra.jl) and take a look at some of the issues for ideas!
