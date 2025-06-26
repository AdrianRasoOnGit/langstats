#' Generate n-grams from text or tokens
#'
#' This function generates sets of n-grams of the size n selected in the function. It supports text input, and data frame input, handled by the function input_handling().
#'
#' @param input Text vector, whose elements can be phrases or documents, or data frame, for example, from the output of ngram(). Bear in mind that, as it has been defined, words must be on the first column! (Not anymore, input_handling() has acquired smart features!)
#' @param n Integer. The size of the n-grams to generate (e.g., 2 for bigrams). Just in case: it must be positive!
#' @param level As in other functions in langstats, allows the user to define the linguistic layer we aim to study, whether it is word, or letter
#'
#' @return A data frame with columns: (1) actual ngram, (2) integer vector of counts for each ngram, and (3) proportion of total n-grams.
#'
#' @examples
#' # Example with plain text (Cauchy, 1821: 1)
#' ngrams("In speaking of the continuity of functions, I could not dispense with a treatment of the principal properties of infinitely small quantities, properties which serve as the foundation of the infinitesimal calculus.", n = 2)
#'
#' # Example with a data frame
#' df <- data.frame(word = c("Cauchy", "functions", "limits"), frequency = c(3, 10, 0))
#' input_handling(df, level = "word")
#'
#' @export
ngrams <- function(input, n = 2, level = c("word", "letter")) {
  level <- match.arg(level)

  # Check if the ngram requested is a valid kind of ngram
  if (!is.numeric(n) || length(n) != 1 || n <= 0) {
    stop("Remember! Parameter 'n' must be a single positive integer.")
  }

  # Use input_handling to standardize input
  input <- input_handling(input, level = level)
  tokens <- input$elements

  if (length(tokens) == 0) {
    warning("Caution! No tokens have been found in the input provided. Was it the right sample?")
    return(data.frame(ngram = character(), frequency = integer(), proportion = numeric()))
  }
  if (n > length(tokens)) {
    stop(sprintf("Caution! The 'n' provided is a bit greater than the number of tokens from the input. Try again with a smaller 'n'"))
  }

  # Generation of n-grams with a sliding window
  ngrams_list <- vapply(seq_len(length(tokens) - n + 1), function(i) {
    paste(tokens[i:(i + n - 1)], collapse = " ")
  }, character(1))

  # Storage of ngrams on a tabular form
  freq_table <- table(ngrams_list)
  freq_vec <- as.integer(freq_table)

  # Data frame building
  data.frame(
    ngram = names(freq_table),
    frequency = freq_vec,
    proportion = freq_vec / sum(freq_vec),
    stringsAsFactors = FALSE
  )
}
