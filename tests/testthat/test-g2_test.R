test_that("g2() returns correct structure for valid 2x2 matrix!", {
  mat <- matrix(c(30, 70, 20, 880), nrow = 2, byrow = TRUE)
  result <- g2(mat)

  expect_type(result, "list")
  expect_named(result, c("G2", "df", "p_value", "expected"))
  expect_type(result$G2, "double")
  expect_type(result$p_value, "double")
  expect_equal(result$df, 1)
  expect_equal(dim(result$expected), c(2, 2))
})

test_that("g2() handles zeros without error!", {
  mat <- matrix(c(0, 10, 20, 30), nrow = 2)
  result <- g2(mat)

  expect_type(result, "list")
  expect_true(result$G2 >= 0)
  expect_true(result$p_value <= 1)
})

test_that("g2() throws error on non-2x2 matrix!", {
  mat1 <- matrix(1:9, nrow = 3)
  mat2 <- matrix(1:4, nrow = 4)

  expect_error(g2(mat1), "Input must be a 2x2 matrix")
  expect_error(g2(mat2), "Input must be a 2x2 matrix")
})

test_that("g2() gives low p-value for strong association!", {
  mat <- matrix(c(90, 10, 10, 90), nrow = 2)
  result <- g2(mat)

  expect_true(result$p_value < 0.01)
})
