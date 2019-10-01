# Spectra.jl

Utilities for interfacing with astronomical spectra and synthetic spectra libraries.

```@contents
Pages = ["index.md", "spectrum.md", "transforms.md"]
```

## Installation

From the REPL, press `]` to enter Pkg mode
```julia
(v 1.2) pkg> add https://github.com/JuliaAstro/Spectra.jl

julia> using Spectra
```

## Quick Start

Here is a quick demo of some of our features

```jldoctest guide
julia> using Spectra, FITSIO, Unitful, UnitfulAstro, Plots

julia> download("https://dr14.sdss.org/optical/spectrum/view/data/format=fits/spec=lite?plateid=1323&mjd=52797&fiberid=12", "sdss.fits");

julia> f = FITS("sdss.fits")
File: sdss.fits
Mode: "r" (read-only)
HDUs: Num  Name     Type   
      1             Image  
      2    COADD    Table  
      3    SPECOBJ  Table  
      4    SPZLINE  Table  

julia> wave = 10 .^ read(f[2], "loglam") * u"angstrom";

julia> flux = read(f[2], "flux") .* 1e-17 * u"erg/s/cm^2/angstrom";

julia> spec = spectrum(wave, flux)
UnitfulSpectrum (3827,)
  λ (Å) f (erg Å^-1 cm^-2 s^-1)

julia> plot(spec);

```

![](assets/sdss.svg)

```jldoctest guide
julia> cont_fit = continuum(spec)
UnitfulSpectrum (3827,)
  λ (Å) f (erg Å^-1 cm^-2 s^-1)
  coeffs: [-5.79625947830634e-14, 4.1205596448044784e-14, 9.024217584841591e-15, -9.262214143923362e-14]
  normalized: true

julia> plot(cont_fit, xlims=(6545, 6600));

```

![](assets/sdss_cont.svg)

```jldoctest guide
julia> line = cont_fit * Region(6565u"angstrom", 6577u"angstrom")
UnitfulSpectrum (8,)
  λ (Å) f (erg Å^-1 cm^-2 s^-1)
  region: [6565 Å, 6577 Å]
  coeffs: [-5.79625947830634e-14, 4.1205596448044784e-14, 9.024217584841591e-15, -9.262214143923362e-14]
  normalized: true

julia> equivalent_width(line)
-15.435962434269147 Å

```

## Citation

If you found this software or any derivative work useful in your academic work, I ask that you please cite the code.

```
TODO
```

## Contributing

Please see [Contributing](@ref contrib) for information on contributing and extending Spectra.jl.
