using Distributions

export GaussianKernel, BoxKernel, RotationalKernel, evaluate

"""
    abstract type Kernel

Kernels serve as the backbone of broadening and convolution operations.
All kernels have a common interface:

    evaluate(::Kernel; maxwidth=8, length=100)

which provides the evaluated PDF of the kernel. Note that the user should not
have to provide the evaluated points, so each kernel should have a way of
automatically choosing its range. For instance, a Gaussian kernel may choose to
automatically evaluate 1000 points from -8σ to 8σ.
"""
abstract type Kernel end

evaluate(k::Kernel; maxwidth = 8, length = 101) = k.(_bounds(k, maxwidth, length))

## Implementation Note
# For each new kernel, implement a _pdf function and _bounds function as below
# which serves as the functional form of your kernel this way, we can limit the
# amount of redefinitions of evaluate.

"""
    GaussianKernel(σ::Number) <: Kernel

This is a simple Gaussian kernel which is evaluated as a normal distribution with variance σ^2 and a pdf of

```math
p(x) = \\frac{1}{σ\\sqrt{2π}} exp\\left(-\\frac{x^2}{2σ^2}\\right)
```

The default evaluation width is ± 4σ.
"""
struct GaussianKernel <: Kernel
    σ::Number
end
(k::GaussianKernel)(x) = Normal(0, k.σ).pdf(x)
_bounds(k::GaussianKernel, width, n) = range(-width / 2 * k.σ, width / 2 * k.σ, length = n)

"""
    BoxKernel(width::Number) <: Kernel

This is a simple Box (top-hat) kernel with a pdf of

```math
p(x) = \\begin{cases}
    1/width & \\abs{x} < width/2 \\
    0 & \\
\\end{cases}
```

The default evaluation width is `± 4*width`
"""
struct BoxKernel <: Kernel
    width::Number
end
(k::BoxKernel)(x) = Uniform(-k.width / 2, k.width / 2).pdf(x)
_bounds(k::BoxKernel, width, n) = range(-width / 2 * k.width, width / 2 * k.width, length = n)

struct RotationalKernel{T <: Number} <: Kernel
    dv::T
    vsini::T
end

RotationalKernel(dv, vsini) = RotationalKernel(promote(dv, vsini)...)
