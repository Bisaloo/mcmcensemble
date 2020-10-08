test_that("multiplication works", {

  p.log <- function(x) {
    B <- 0.03
    return(-x[1]^2/200 - 1/2*(x[2]+B*x[1]^2-100*B)^2)
  }

  res1 <- MCMCEnsemble(p.log, lower.inits=c(a=0, b=0), upper.inits=c(a=1, b=1),
                       max.iter=3000, n.walkers=10, method="s")

  expect_type(res1, "list")
  expect_length(res1, 2)
  expect_named(res1, c("samples", "log.p"))

  expect_identical(dim(res1$samples), c(10L, 300L, 2L))
  expect_identical(dim(res1$samples)[1:2], dim(res1$log.p))

  expect_identical(dimnames(res1$samples)[[3]], c("a", "b"))

  res2 <- MCMCEnsemble(p.log, lower.inits=c(0, 0), upper.inits=c(a=1, b=1),
                       max.iter=3000, n.walkers=10, method="s")

  expect_identical(dimnames(res1$samples)[[3]], c("para_1", "para_2"))

  res3 <- MCMCEnsemble(p.log, lower.inits=c(a=0, b=0), upper.inits=c(a=1, b=1),
                       max.iter=3000, n.walkers=10, method="d", coda=TRUE)

  expect_s3_class(res3$samples, "mcmc.list")

})