#' Generate n-grams from text or tokens
#'
#' This function creates n-grams of size \code{n} from the input text or token vector.
#' It supports raw text input (which it tokenizes by whitespace by default),
#' a custom tokenizer function, or a pre-tokenized character vector.
#'
#' @param text A character string containing raw text, or a character vector of tokens.
#' @param n Integer. The size of the n-grams to generate (e.g., 2 for bigrams).
#'   Must be a positive integer.
#' @param tokenizer Optional. Either \code{NULL} (default) to tokenize \code{text} by whitespace,
#'   a function that takes \code{text} as input and returns a character vector of tokens,
#'   or a character vector of tokens itself. If \code{text} is already tokenized,
#'   pass \code{text} as \code{tokenizer}.
#'
#' @return A \code{data.frame} with columns: (1) ngram, (2) integer vector of counts for each ngram, and (3) proportion of total n-grams.
#' }
#'
#' @examples
#' # Using raw text input
#' ngrams("this is a test sentence", n = 2)
#'
#' # Using a custom tokenizer function
#' tokenize_words <- function(text) unlist(strsplit(tolower(text), "\\W+"))
#' ngrams("This is another test.", n = 3, tokenizer = tokenize_words)
#'
#' # Using pre-tokenized input
#' tokens <- c("the", "quick", "brown", "fox")
#' ngrams(text = tokens, n = 2, tokenizer = tokens)
#'
#' @export
ngrams <- function(text, n = 2, tokenizer = NULL) {
  if (!is.numeric(n) || length(n) != 1 || n <= 0) {
    stop("Parameter 'n' must be a single positive integer.")
  }

  if (is.null(tokenizer)) {
    tokens <- tolower(unlist(strsplit(text, "\\W+")))
  } else if (is.function(tokenizer)) {
    tokens <- tokenizer(text)
  } else if (is.character(tokenizer)) {
    tokens <- tokenizer
  } else {
    stop("'tokenizer' must be NULL, a function, or a character vector of tokens.")
  }

  if (length(tokens) == 0) {
    warning("No tokens found in text.")
    return(data.frame(ngram = character(), frequency = integer(), proportion = numeric()))
  }
  if (n > length(tokens)) {
    warning("'n' is greater than the number of tokens. Returning empty data frame.")
    return(data.frame(ngram = character(), frequency = integer(), proportion = numeric()))
  }

  ngrams_list <- vapply(seq_len(length(tokens) - n + 1), function(i) {
    paste(tokens[i:(i + n - 1)], collapse = " ")
  }, character(1))

  freq_table <- table(ngrams_list)
  freq_vec <- as.integer(freq_table)

  data.frame(
    ngram = names(freq_table),
    frequency = freq_vec,
    proportion = freq_vec / sum(freq_vec),
    stringsAsFactors = FALSE
  )
}
