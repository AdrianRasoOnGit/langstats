test_that("plot_ls handles zipf() output", {
  df <- data.frame(
    word = c("a", "b", "c"),
    frequency = c(100, 50, 25),
    rank = c(1, 2, 3)
  )
  p <- plot_ls(df)
  expect_s3_class(p, "ggplot")
})



test_that("plot_ls handles collocation G2 output", {
  df <- data.frame(
    ngram = c("a b", "c d", "e f"),
    G2 = c(15.2, 10.1, 8.7),
    p_value = c(0.01, 0.05, 0.07)
  )
  p <- plot_ls(df)
  expect_s3_class(p, "ggplot")
})


test_that("plot_ls throws on unknown input", {
  df <- data.frame(x = 1:5, y = 6:10)
  expect_error(plot_ls(df), "doesn't recognize this object", fixed = TRUE)
})
