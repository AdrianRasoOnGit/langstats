test_that("ngrams() correctly generates bigrams from text!", {
  text <- "this is a test of ngram generation"
  result <- ngrams(text, n = 2)

  expect_true(is.data.frame(result))
  expect_true(all(c("ngram", "frequency", "proportion") %in% names(result)))
  expect_true(all(result$frequency > 0))
  expect_equal(sum(result$proportion), 1, tolerance = 1e-6)
  expect_true(all(grepl(" ", result$ngram)))  # all bigrams contain space
})

test_that("ngrams() correctly generates trigrams from text!", {
  text <- "this is a test"
  result <- ngrams(text, n = 3)

  expect_equal(nrow(result), 2)  # "this is a", "is a test"
})

test_that("ngrams() works with data frame input!", {
  df <- data.frame(word = c("hello", "world", "langstats"), frequency = c(3, 2, 1))
  result <- ngrams(df, n = 2)

  expect_true(is.data.frame(result))
  expect_equal(ncol(result), 3)
  expect_equal(names(result), c("ngram", "frequency", "proportion"))
})

test_that("ngrams() returns empty frame if input has no tokens", {
  expect_warning({
    result <- ngrams("", n = 2)
    expect_equal(nrow(result), 0)
  }, "No tokens have been found")
})

test_that("ngrams() fails when n is not valid!", {
  text <- "a b c"
  expect_error(ngrams(text, n = 0), "must be a single positive integer")
  expect_error(ngrams(text, n = -1), "must be a single positive integer")
  expect_error(ngrams(text, n = 100), "bit greater than the number of tokens")
})
