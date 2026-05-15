# SpectrumBase.jl

[![](https://img.shields.io/badge/docs-stable-blue.svg?label=docs)](https://juliaastro.org/SpectrumBase.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg?label=docs)](https://juliaastro.org/SpectrumBase.jl/dev)

[![CI](https://github.com/JuliaAstro/SpectrumBase.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaAstro/SpectrumBase.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/juliaastro/SpectrumBase.jl/graph/badge.svg?token=EjMJcszaoQ)](https://codecov.io/gh/juliaastro/SpectrumBase.jl)
![GitHub](https://img.shields.io/github/license/juliaastro/SpectrumBase.jl.svg)

Utilities for interfacing with astronomical spectra and synthetic spectra libraries.

**Warning: This is a work in progress and is under heavy development**

**Primary Author:** Miles Lucas [@mileslucas](https://github.com/mileslucas)

## Installation

Currently this package can only be installed from github. To do so, either clone this repository and install it or

    pkg> add https://github.com/JuliaAstro/SpectrumBase.jl

from the `pkg` command line (Press `]` from Julia REPL)

## Developer documentation

Below we show the commands to run from the package root level to develop the tests and documentation.

### Tests

```julia-repl
julia --proj

julia> import Pkg

# List tests
julia> Pkg.test("SpectrumBase"; test_args = `--list`)

# Run specific testsets by name. Will match with `startswith`
julia> Pkg.test("SpectrumBase"; test_args = `--verbose <testset name>`)
```

### Docs

Assuming `LiveServer.jl` is in your global environment:

```julia-repl
julia --proj=docs/

julia> using LiveServer

julia> servedocs(; include_dirs = ["src/"])
```
