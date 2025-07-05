test_that("tf works on multiple documents!", {
  texts <- c("this is an important document! some contents..., some more...", "oh! this is another really important document! contents!... some more contents here yet...")
  result <- tf(texts)
  expect_true("tf" %in% names(result))
  expect_true(any(result$tf > 0))
})

test_that("idf returns expected columns!", {
  texts <- c("Cauchy founded current analysis", "Weierstrass founded current analysis", "Bolzano founded current analysis")
  result <- idf(texts)
  expect_equal(colnames(result), c("term", "idf"))
})
