#' Bag of Words
#'
#' It builds a frequency table of tokens from a text or corpus, with frequencies of each token and proportion of the sample. Currently, it's quite close to what input_handling() does, but this function does not have any internal role in langstats: it's for the user to check token frequencies in an automatic and easy way.
#'
#' @param text Text vector, whose elements can be phrases or documents. Note that both can be just one word
#' @param level It can be word or letter
#' @param sort Boolean value that lets the user define whether the order of the tokens will be based on most frequent or alphabetical order
#' @return A data.frame, whose columns will be: (1) token, (2) frequency, (3) proportion
#' @examples
#'
#' # Example with a long text (Fisher, 1935: 6)
#' text1 <- "The discrepancy of opinion among historical writers on probability is so great that to mention the subject is unavoidable. It would, however, be out of place here to argue the point in detail. I will only state three considerations which will explain why, in the practical applications of the subject, I shall not assume the truth of Bayes’ axiom. Two of these reasons would, I think, be generally admitted, but the first, I can well imagine, might be indignantly repudiated in some quarters."
#' bow(text1)
#'
#' # Example with multiple documents
#' text2 <- c("Bayes is from England", "Bayes is a statistician", "Bayes formulated Bayes Theorem")
#' bow(text2)
#'
#' @export
bow <- function(text, level = c("word", "letter"), sort = TRUE) {
  level <- match.arg(level)

  # Check if the input is an actual text vector
  if (!is.character(text)) stop("Remember! Input must be a text vector. Check ?bow for further indications.")

  # Turn capital letters to lowercase
  text <- tolower(text)

  if (level == "word") {
  # Tokenize words
    tokens <- unlist(strsplit(text, "\\W+"))
  } else {
  #Tokenize letters
    tokens <- unlist(strsplit(text, ""))
  }

  # Ignore null tokens
  tokens <- tokens[tokens != ""]

  # Store of tokens
  freq <- table(tokens)

  # Data frame building, with (1) token, (2) frequency, and (3) proportion in the text
  df <- data.frame(
    token = names(freq),
    frequency = as.integer(freq),
    proportion = as.numeric(freq) / sum(freq)
  )

  # Sorting of tokens at will
  if (sort) df <- df[order(-df$frequency), ]

  # Remove numbers of rows
  rownames(df) <- NULL
  df
}

