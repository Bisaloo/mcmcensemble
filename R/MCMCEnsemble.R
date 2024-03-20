#' MCMC ensemble sampler
#'
#' Ensemble Markov Chain Monte Carlo sampler with different strategies to
#' generate proposals. Either the *stretch move* as proposed by Goodman and
#' Weare (2010), or a *differential evolution jump move* similar to Braak and
#' Vrugt (2008).
#'
#' @param f function that returns a single scalar value proportional to the log
#'   probability density to sample from.
#' @param inits A matrix (or data.frame) containing the starting values for the
#'   walkers. Each column is a variable to estimate and each row is a walker
#' @param max.iter maximum number of function evaluations
#' @param n.walkers number of walkers (ensemble size). An integer greater or
#'   equal than 2.
#' @param method method for proposal generation, either `"stretch"`, or
#'   `"differential.evolution"`. This argument will be saved as an attribute
#'   in the output (see examples).
#' @param coda logical. Should the samples be returned as [coda::mcmc.list]
#'   object? (defaults to `FALSE`)
#' @param ... further arguments passed to `f`
#'
#' @return
#' * if `coda = FALSE` a list with:
#'   - *samples*: A three dimensional array of samples with dimensions `walker`
#'     x `generation` x `parameter`
#'   - *log.p*: A matrix with the log density evaluate for each walker at each
#'      generation.
#' * if `coda = TRUE` a list with:
#'   - *samples*: A object of class [coda::mcmc.list] containing all samples.
#'   - *log.p*: A matrix with the log density evaluate for each walker at each
#'     generation.
#'
#' In both cases, there is an additional attribute (accessible via
#' `attr(res, "ensemble.sampler")`) recording which ensemble sampling algorithm
#' was used.
#'
#' @examples
#' ## a log-pdf to sample from
#' p.log <- function(x) {
#'     B <- 0.03                              # controls 'bananacity'
#'     -x[1]^2/200 - 1/2*(x[2]+B*x[1]^2-100*B)^2
#' }
#'
#' ## set options and starting point
#' n_walkers <- 10
#' unif_inits <- data.frame(
#'   "a" = runif(n_walkers, 0, 1),
#'   "b" = runif(n_walkers, 0, 1)
#' )
#'
#'
#' ## use stretch move
#' res1 <- MCMCEnsemble(p.log, inits = unif_inits,
#'                      max.iter = 300, n.walkers = n_walkers,
#'                      method = "stretch")
#'
#' attr(res1, "ensemble.sampler")
#'
#' str(res1)
#'
#'
#' ## use stretch move, return samples as 'coda' object
#' res2 <- MCMCEnsemble(p.log, inits = unif_inits,
#'                      max.iter = 300, n.walkers = n_walkers,
#'                      method = "stretch", coda = TRUE)
#'
#' attr(res2, "ensemble.sampler")
#'
#' summary(res2$samples)
#' plot(res2$samples)
#'
#'
#' ## use different evolution move, return samples as 'coda' object
#' res3 <- MCMCEnsemble(p.log, inits = unif_inits,
#'                      max.iter = 300, n.walkers = n_walkers,
#'                      method = "differential.evolution", coda = TRUE)
#'
#' attr(res3, "ensemble.sampler")
#'
#' summary(res3$samples)
#' plot(res3$samples)
#'
#' @export
#'
#' @references
#' - ter Braak, C. J. F. and Vrugt, J. A. (2008) Differential Evolution Markov
#' Chain with snooker updater and fewer chains. Statistics and Computing, 18(4),
#' 435–446, \doi{10.1007/s11222-008-9104-9}
#' - Goodman, J. and Weare, J. (2010) Ensemble samplers with affine invariance.
#' Communications in Applied Mathematics and Computational Science, 5(1), 65–80,
#' \doi{10.2140/camcos.2010.5.65}
#'
MCMCEnsemble <- function(f, inits, max.iter, n.walkers = 10 * ncol(inits),
                         method = c("stretch", "differential.evolution"),
                         coda = FALSE, ...) {

  if (is.data.frame(inits) || inherits(inits, "tbl_df")) {
    inits <- as.matrix(inits)
  }

  if (n.walkers < 2) {
    stop("The number of walkers must be at least 2", call. = FALSE)
  }

  if (nrow(inits) != n.walkers) {
    stop(
      "The number of rows of `inits` must be equal to `n.walkers`",
      call. = FALSE
    )
  }

  ## run mcmc
  method <- match.arg(method)
  message("Using ", method, " move with ", n.walkers, " walkers.")

  if (method == "differential.evolution") {
    res <- d.e.mcmc(f, inits, max.iter, n.walkers, ...)
  }
  if (method == "stretch") {
    res <- s.m.mcmc(f, inits, max.iter, n.walkers, ...)
  }

  ## add names
  if (is.null(colnames(inits))) {
    pnames <- paste0("para_", seq_len(ncol(inits)))
  } else {
    pnames <- colnames(inits)
  }
  dimnames(res$samples) <- list(
    paste0("walker_", seq_len(n.walkers)),
    paste0("generation_", seq_len(ncol(res$samples))),
    pnames
  )

  dimnames(res$log.p) <- list(
    paste0("walker_", seq_len(n.walkers)),
    paste0("generation_", seq_len(ncol(res$samples)))
  )

  ## convert to coda object
  if (coda) {

    if (!requireNamespace("coda", quietly = TRUE)) {
      stop(
        "Package 'coda' needed for to create coda objects. ",
        "Please install it or use `coda = FALSE`.",
        call. = FALSE
      )
    }

    ll <- lapply(seq_len(n.walkers),
                 function(w) coda::as.mcmc(res$samples[w, , ]))
    res <- list(samples = coda::as.mcmc.list(ll), log.p = res$log.p)
  }

  attr(res, "ensemble.sampler") <- method

  return(res)
}
