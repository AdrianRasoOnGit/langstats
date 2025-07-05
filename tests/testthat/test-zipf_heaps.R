test_that("zipf() returns a ranked data frame with expected columns!", {
  text <- "Although many attack Zipf for not being that precise statisticswise, at the end of the day he found the distribution!"
  result <- zipf(text)

  expect_true(is.data.frame(result))
  expect_true(all(c("word", "frequency", "rank") %in% names(result)))
  expect_type(result$word, "character")
  expect_type(result$frequency, "integer")
  expect_type(result$rank, "integer")
  expect_true(all(diff(result$frequency) <= 0))  # frequencies sorted
  expect_equal(result$rank, seq_len(nrow(result)))
})

test_that("zipf() works with data frame input!", {
  df <- data.frame(word = c("a", "b", "a", "c", "b", "a"), frequency = c(1, 1, 1, 1, 1, 1))
  result <- zipf(df)

  expect_true(is.data.frame(result))
  expect_true(all(c("word", "frequency", "rank") %in% names(result)))
  expect_true("a" %in% result$word)
})

test_that("heaps() returns a growing vocabulary table!", {
  text <- rep("a b c d", 10)
  result <- heaps(text)

  expect_true(is.data.frame(result))
  expect_true(all(c("tokens", "vocabulary") %in% names(result)))
  expect_equal(nrow(result), length(unlist(strsplit(text, " "))))
  expect_true(all(diff(result$vocabulary) >= 0))  # vocabulary should grow or stay
})

test_that("heaps() handles very short text!", {
  text <- "x y"
  result <- heaps(text)

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$vocabulary, c(1, 2))
})
