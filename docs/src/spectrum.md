# Spectrum

Here we will go over the `Spectrum` type and how we can use it to interact with spectra.

## The `Spectrum` Type

### Basic operations
```@docs
Spectrum
length
size
```

### Arithmetic
The following basic arithmetic is provided

Function           | Notes 
:------------------|:-----------------------------------------------------------
`+(::Spectrum, A)` | 
`-(::Spectrum, A)` |
`*(::Spectrum, A)` | `sigma` updated by $\sigma \left\lvert A \right\rvert$
`/(::Spectrum, A)` | `sigma` updated by $\sigma \left\lvert A \right\rvert^{-1}$

### Unitful helpers

```@docs
unit
ustrip
```

## Index

```@index
```