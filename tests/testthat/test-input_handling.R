test_that("input_handling processes basic text input correctly!", {
  text <- c("Codd is English", "Codd studied in Oxford")
  result <- input_handling(text, level = "word")

  expect_type(result, "list")
  expect_true(all(c("elements", "freqs", "probs") %in% names(result)))
  expect_true(is.character(result$elements))
  expect_true(is.numeric(result$freqs))
  expect_equal(sum(result$probs), 1, tolerance = 1e-6)
})

test_that("input_handling handles data frame input with token and frequency columns!", {
  df <- data.frame(word = c("Codd", "model"), frequency = c(10, 5))
  result <- input_handling(df, level = "word")

  expect_type(result, "list")
  expect_equal(names(result$freqs), tolower(df$word))
  expect_equal(unname(result$freqs), df$frequency)
  expect_equal(sum(result$probs), 1, tolerance = 1e-6)
})

test_that("input_handling handles text at letter level!", {
  text <- "ABC"
  result <- input_handling(text, level = "letter")
  expect_true(all(result$elements %in% c("a", "b", "c")))
  expect_equal(sum(result$freqs), 3)
})

test_that("input_handling handles data frames without frequency column!", {
  df <- data.frame(element = c("Codd", "model", "relational"))
  result <- input_handling(df, level = "word")

  expect_type(result, "list")
  expect_null(result$freqs)
  expect_true(length(result$elements) > 0)
})

test_that("input_handling returns empty result on NA or empty text!", {
  result1 <- input_handling(NA_character_)
  result2 <- input_handling("")

  expect_equal(result1$elements, character())
  expect_null(result1$freqs)
  expect_equal(result2$elements, character())
  expect_null(result2$freqs)
})

test_that("input_handling throws on invalid input type!", {
  expect_error(input_handling(42))
  expect_error(input_handling(TRUE))
})
