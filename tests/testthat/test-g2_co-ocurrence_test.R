test_that("collocation_g2 returns ranked bigrams from text input!", {
  text <- "data science is science about data and learning from data"
  result <- collocation_g2(text, top_n = 5)

  expect_true(is.data.frame(result))
  expect_true(all(c("ngram", "word1", "word2", "count", "G2", "p_value") %in% names(result)))
  expect_lte(nrow(result), 5)
  expect_true(all(result$G2 >= 0))
})

test_that("collocation_g2 works when querying a specific bigram!", {
  text <- "language models generate language with language structure"
  result <- collocation_g2(text, word1 = "language", word2 = "models")

  expect_type(result, "list")
  expect_true("G2" %in% names(result))
  expect_equal(result$ngram, "language models")
  expect_equal(dim(result$table), c(2, 2))
})

test_that("collocation_g2 handles missing bigram gracefully!", {
  text <- "the quick brown fox"
  result <- collocation_g2(text, word1 = "blue", word2 = "moon")

  expect_equal(result$ngram, "blue moon")
  expect_equal(sum(result$table), sum(ngrams(text, n = 2)$frequency))
  expect_type(result$G2, "double")
})

test_that("collocation_g2 works on precomputed ngram data!", {
  df <- data.frame(
    ngram = c("deep learning", "learning systems", "systems design"),
    frequency = c(10, 5, 2),
    proportion = c(0.5, 0.3, 0.2)
  )

  result <- collocation_g2(df, top_n = 2)
  expect_true(is.data.frame(result))
  expect_equal(ncol(result), 6)
})
