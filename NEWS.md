# mcmcensemble 3.2.0

## Bug fixes

* a bug resulting in weak correlation across walkers has been resolved (#9, @scheidan). Runs from this version will therefore produce results different than with previous versions, even for a given seed.

## Minor improvements

Two changes ensure chains don't get stuck in a loop:

* an early parameter check ensures that sufficient walkers are provided (via the `n.walkers` argument) to ensure ergodicity (#11, @scheidan)
* noise has been added to each step of the differential evolution algorithm to ensure we don't end up walking on a grid (#12, @scheidan)

# mcmcensemble 3.1.0

## Minor improvements

* there is now a clearer error message when trying to use a single walker since
ensemble sampling is designed to work with multiple walkers (#6 by @Bisaloo,
based on a report from @adamkucharski).

# mcmcensemble 3.0.0

## Major changes

* the arguments `lower.inits` and `upper.inits` are deprecated in favour of
`inits` which leave more flexibility to the user. Please read the detailed
blog post for more background about this change and how to migrate.
* `inits` can now be a `data.frame` or a `matrix`
* `d.e.mcmc()` and `s.m.mcmc()` are not exported any more. Please use the
wrapper `MCMCEnsemble()` instead.
* there is a new vignette
(`vignette("diagnostic-pkgs", package = "mcmcensemble")`) presenting two
different options (coda and bayesplot) to plot and evaluate the MCMC chains
produced by mcmcensemble.

## Bug fixes

* The chains now run fine even in the case where there is only one iteration
(i.e., `max.iter %/% n.walkers == 1`)
* The error message when the coda package is absent and `coda = TRUE` now
correctly prompt the user to use `coda = FALSE` if they do not wish to install
coda.

# mcmcensemble 2.2.0

## Major changes

* it is now possible to use a named vector as first argument of the function
passed in `f`. This is useful if you do something like:

```r
p.log.named <- function(x) {
  B <- 0.03
  return(-x["a"]^2/200 - 1/2*(x["b"]+B*x["a"]^2-100*B)^2)
}
```
* mcmcensemble now explicitly depends on R >= 3.5.0. This was already implicitly
the case since 2.1 because of the dependency on the progressr package.
* the ensemble sampling algorithm used by `MCMCEnsemble()` is now recorded in
an additional attribute (accessible via `attr(res, "ensemble.sampler")`).

## Other user-facing changes

* there is now an additional argument check ensuring that `lower.inits` and
`upper.inits` have the same names

# mcmcensemble 2.1

## Major changes

* the ensemble sampling can now be parallelised with the future framework. Check
the [README](https://hugogruson.fr/mcmcensemble/) for more information

## Other user-facing changes

* very large log.p differences between chains do not cause them to be
stuck any more
* addition of a new vignette listing frequently asked questions (with their
answer)

## Dev changes

* new test to make sure the chains converge as expected
* performance improvements

# mcmcensemble 2.0

## Breaking changes

* The argument names and order in `d.e.mcmc()` and `s.m.mcmc()` now match those
of `MCMCEnsemble()`

## Other user-facing changes

* coda package is now only in `Suggests`, instead of being a hard dependency

## Dev changes

* this package is now named mcmcensemble
* roxygen2 documentation now uses markdown syntax
* this package now has unit and regression tests
* various parts of the code have been optimized for speed
