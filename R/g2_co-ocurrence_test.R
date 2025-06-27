#' G² lexical co-ocurrence test
#'
#' Applies the G² statistic for a given word pair, or all word pairs in a bigram list.
#' If word1 and word2 are not provided, it ranks all bigrams by significance (quite heavy to load sometimes, bear that in mind!)
#'
#' @param input A data frame of ngrams (probably from ngrams()) or a text vector (no bag of words allowed here).
#' @param word1 Optional. First word in a bigram.
#' @param word2 Optional. Second word in a bigram.
#' @param top_n Integer. Size of the query of results.
#'
#' @return If word1 and word2 are given, a G² test result. Otherwise, a data frame of bigrams ranked by G² score (most significant collocations, that's what it is).
#' @export
collocation_g2 <- function(input, word1 = NULL, word2 = NULL, top_n = 20) {

  # If input is not a valid ngram data frame, use ngrams()
  if (!is.data.frame(input) || !"ngram" %in% names(input)) {
    input <- ngrams(input, n = 2, level = "word")
  }

  ngram_df <- input
  names(ngram_df)[1:2] <- c("ngram", "count")  # standardize names
  total_bigrams <- sum(ngram_df$count)

  # If specific bigram is requested
  if (!is.null(word1) && !is.null(word2)) {
    target_bigram <- paste(word1, word2)
    A <- ngram_df$count[ngram_df$ngram == target_bigram]
    A <- ifelse(length(A) == 0, 0, A)

    B <- sum(ngram_df$count[grepl(paste0("^", word1, " "), ngram_df$ngram)]) - A
    C <- sum(ngram_df$count[grepl(paste0(" ", word2, "$"), ngram_df$ngram)]) - A
    D <- total_bigrams - (A + B + C)

    observed <- matrix(c(A, B, C, D), nrow = 2, byrow = TRUE,
                       dimnames = list(c("word1_present", "word1_absent"),
                                       c("word2_present", "word2_absent")))
    result <- g2(observed)
    result$ngram <- target_bigram
    result$table <- observed
    return(result)
  }

  # Otherwise: discover all significant collocations
  split_words <- strsplit(ngram_df$ngram, " ")
  bigram_words <- do.call(rbind, split_words)
  colnames(bigram_words) <- c("word1", "word2")

  # It is really advisable to optimize the operations that the function may carry out with this chunk
  start_counts <- tapply(ngram_df$count, bigram_words[, 1], sum)
  end_counts   <- tapply(ngram_df$count, bigram_words[, 2], sum)

  scores <- lapply(seq_len(nrow(ngram_df)), function(i) {
    w1 <- bigram_words[i, 1]
    w2 <- bigram_words[i, 2]
    A <- ngram_df$count[i]
    B <- start_counts[w1] - A
    C <- end_counts[w2] - A
    D <- total_bigrams - (A + B + C)


  observed <- matrix(c(A, B, C, D), nrow = 2, byrow = TRUE)
  g2_result <- g2(observed)

    data.frame(
      ngram = ngram_df$ngram[i],
      word1 = w1,
      word2 = w2,
      count = A,
      G2 = g2_result$G2,
      p_value = g2_result$p_value
    )
  })

  result_df <- do.call(rbind, scores)
  result_df <- result_df[order(-result_df$G2), ]
  return(head(result_df, top_n))
}
