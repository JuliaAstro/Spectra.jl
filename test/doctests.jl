using SpectrumBase
using Documenter: DocMeta, doctest

DocMeta.setdocmeta!(SpectrumBase, :DocTestSetup, :(using SpectrumBase); recursive = true)

# Julia qualifies a type name (e.g. `Quantity` vs `Unitful.Quantity`) based on
# whether its parent module is in scope, and that scope differs between the doc
# build and the test suite (and even between a standalone run and ParallelTestRunner).
# Normalize the optional `Unitful.`/`Measurements.` prefixes so the doctests are
# robust to where they are run from. The prefix must be optional in the regex: a
# Documenter filter is only applied when it matches *both* the expected and actual
# output, and the expected output is written with the unqualified names.
doctest(
    SpectrumBase;
    doctestfilters = [
        r"(Unitful\.)?Quantity" => "Quantity",
        r"(Measurements\.)?Measurement" => "Measurement",
    ],
)
