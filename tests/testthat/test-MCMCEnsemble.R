p.log <- function(x) {
  B <- 0.03
  return(-x[1]^2 / 200 - 1 / 2 * (x[2] + B * x[1]^2 - 100 * B)^2)
}

unif_inits <- data.frame(
  a = runif(10),
  b = runif(10)
)

test_that("output sizes and names", {
  res1 <- MCMCEnsemble(
    p.log,
    inits = unif_inits,
    max.iter = 300,
    n.walkers = 10,
    method = "s"
  )

  expect_type(res1, "list")
  expect_length(res1, 2)
  expect_named(res1, c("samples", "log.p"))

  expect_identical(dim(res1$samples), c(10L, 30L, 2L))
  expect_identical(dim(res1$samples)[1:2], dim(res1$log.p))
  expect_identical(dimnames(res1$samples)[[3]], c("a", "b"))
  expect_identical(attr(res1, "ensemble.sampler"), "stretch")

  # Also tests if a matrix is accepted instead of a df.
  unnamed_inits <- matrix(runif(20), ncol = 2)
  res2 <- MCMCEnsemble(
    p.log,
    inits = unnamed_inits,
    max.iter = 300,
    n.walkers = 10,
    method = "s"
  )

  expect_identical(dimnames(res2$samples)[[3]], c("para_1", "para_2"))
})

test_that("coda", {
  skip_if_not_installed("coda")

  res3 <- MCMCEnsemble(
    p.log,
    inits = unif_inits,
    max.iter = 300,
    n.walkers = 10,
    method = "d",
    coda = TRUE
  )

  expect_s3_class(res3$samples, "mcmc.list")
  expect_identical(attr(res3, "ensemble.sampler"), "differential.evolution")
})

test_that("errors", {
  expect_error(
    MCMCEnsemble(
      p.log,
      inits = unif_inits[5, ],
      max.iter = 300,
      n.walkers = 10,
      method = "d"
    ),
    "number of rows"
  )

  mockery::stub(MCMCEnsemble, "requireNamespace", FALSE)

  expect_error(
    MCMCEnsemble(
      p.log,
      inits = unif_inits,
      max.iter = 300,
      n.walkers = 10,
      method = "d",
      coda = TRUE
    ),
    "coda"
  )

  fw <- function(x) {
    10 * sin(0.3 * x) * sin(1.3 * x^2) + 0.00001 * x^4 + 0.2 * x + 80
  }

  expect_error(
    MCMCEnsemble(
      fw,
      inits = unif_inits,
      max.iter = 300,
      n.walkers = 10,
      method = "s"
    ),
    "numeric of length 1"
  )

  expect_error(
    MCMCEnsemble(
      fw,
      inits = unif_inits,
      max.iter = 300,
      n.walkers = 10,
      method = "d"
    ),
    "numeric of length 1"
  )
})

test_that("named arguments", {
  set.seed(20200111)
  res1 <- MCMCEnsemble(
    p.log,
    inits = unif_inits,
    max.iter = 300,
    n.walkers = 10,
    method = "s"
  )

  p.log.named <- function(x) {
    B <- 0.03
    return(-x["a"]^2 / 200 - 1 / 2 * (x["b"] + B * x["a"]^2 - 100 * B)^2)
  }

  set.seed(20200111)
  res2 <- MCMCEnsemble(
    p.log.named,
    inits = unif_inits,
    max.iter = 300,
    n.walkers = 10,
    method = "s"
  )

  expect_identical(res1, res2)
})

test_that("minimal number of walkers: stretch", {
  for (dims in 1:3) {
    for (n.walkers in 1:5) {
      inits <- as.data.frame(matrix(
        runif(n.walkers * dims, -1, 1),
        ncol = dims
      ))

      if (n.walkers < max(3, dims + 1)) {
        expect_error(
          MCMCEnsemble(
            p.log,
            inits = inits,
            n.walkers = n.walkers,
            max.iter = 20,
            method = "stretch"
          ),
          "max(3, d+1)",
          fixed = TRUE
        )
      } else {
        expect_no_error(
          MCMCEnsemble(
            p.log,
            inits = inits,
            n.walkers = n.walkers,
            max.iter = 20,
            method = "stretch"
          )
        )
      }
    }
  }
})

test_that("minimal number of walkers: differential evolution", {
  for (dims in 1:3) {
    for (n.walkers in 1:5) {
      inits <- as.data.frame(matrix(
        runif(n.walkers * dims, -1, 1),
        ncol = dims
      ))

      if (n.walkers < max(4, dims + 2)) {
        expect_error(
          MCMCEnsemble(
            p.log,
            inits = inits,
            n.walkers = n.walkers,
            max.iter = 20,
            method = "differential.evolution"
          ),
          "max(4, d+2)",
          fixed = TRUE
        )
      } else {
        expect_no_error(
          MCMCEnsemble(
            p.log,
            inits = inits,
            n.walkers = n.walkers,
            max.iter = 20,
            method = "differential.evolution"
          )
        )
      }
    }
  }
})
