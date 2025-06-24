#' Input handling for functions of langstats: a smart and standard channel for inputs
#'
#' Through input_handling we can extract tokens and frequencies from a variety of input formats. At the moment, it is sensitive to texts, and data frames, the former being a common output in this package, so this standarisaton of inputs can create a really smooth workflow. It detects automatically tokens and frequencies from data frames, and in the case of texts, it tokenises and calculates frequencies, providing a bag of words.
#' like \code{shannon_entropy()}, \code{cross_entropy()}, \code{zipf()}, and \code{heaps()} by detecting
#' token and frequency columns automatically when available.
#'
#' @param input A character vector of text (which can include full documents, sentences, etc.), or a
#' data frame such as the output from \code{ngrams()} or \code{zipf()} that includes tokens and, optionally, frequencies.
#' @param level The unit of analysis: either \code{"word"} or \code{"letter"}.
#'
#' @return A list with two elements:
#' \describe{
#'   \item{\code{elements}}{A character vector of tokens (either words or letters), lowercased and cleaned.}
#'   \item{\code{freqs}}{A numeric vector of relative frequencies (if present in the input); otherwise, \code{NULL}.}
#' }
#'
#' @details
#' If a data frame is provided, the function attempts to automatically detect a token column using common
#' names such as \code{"token"}, \code{"word"}, \code{"element"}, etc. If a frequency column named
#' \code{"frequency"} exists, it is normalized and returned. If only raw text is provided, the function tokenizes
#' using a regular expression based on the \code{level} argument.
#'
#' @examples
#' text <- c("The quick brown fox.", "Jumps over the lazy dog!")
#' process_input(text, level = "word")
#'
#' df <- data.frame(word = c("the", "quick", "brown"), frequency = c(10, 3, 2))
#' process_input(df, level = "word")
#'
#' @keywords internal
#' @export
#'
input_handling <- function(input, level = c("word", "letter")) {
  level <- match.arg(level)

  # Tokenization function definition
  tokenize <- function(x) {
    x <- tolower(x)
    if (level == "word") {
      unlist(strsplit(x, "\\W+"))
    } else {
      unlist(strsplit(x, ""))
    }
  }

  # Check if input is a data frame, and if that's the case, we start looking for tokens
  if (is.data.frame(input)) {
    colnames_lower <- tolower(names(input))

    # Search for tokens. We rely on a bit of clarity from the data frame format; luckily, every output from langstats works here
    candidates_token_cols <- c("token", "tokens", "element", "elements", "word", "words")
    token_col <- intersect(colnames_lower, candidates_token_cols)

    # What if there are no matches? We will assume that the first column is related to words. For that, we add a warning: discretion is advised
    if (length(token_col) == 0) {
      token_col <- names(input)[1]
      warning("Discretion advised: no token column explicitly found! The function is assuming the first column contains the tokens. This column is called: '", token_col, "'. Is it a sound name?")
      elements <- tolower(as.character(input[[token_col]]))
      elements <- elements[!is.na(elements)]

      # Next we will do the same for frequencies
      candidates_freq_cols <- c("frequency", "freq", "count", "counts", "n", "n_tokens")
      freq_col <- intersect(colnames_lower, candidates_freq_cols)

      if (length(freq_col) > 0) {
        freq_col <- names(input)[match(freq_col[1], colnames_lower)]
        raw_freqs <- input[[freq_col]]
        freqs <- raw_freqs / sum(raw_freqs)
      } else {
        freqs <- NULL
      }

      return(list(elements = elements, freqs = freqs))

    } else {
      # Usually, especially in data frames from langstats, token column is found. We storage its values
      token_col <- names(input)[match(token_col[1], colnames_lower)]
      elements <- tolower(as.character(input[[token_col]]))
      elements <- elements[!is.na(elements)]

      # Again, we do the same search for the frequency column
      candidates_freq_cols <- c("frequency", "freq", "count", "counts", "n", "n_tokens")
      freq_col <- intersect(colnames_lower, candidates_freq_cols)

      if (length(freq_col) > 0) {
        freq_col <- names(input)[match(freq_col[1], colnames_lower)]
        raw_freqs <- input[[freq_col]]
        freqs <- raw_freqs / sum(raw_freqs)
      } else {
        freqs <- NULL
      }

      # Here we provide the standard form of inputs in langstats
      return(list(elements = elements, freqs = freqs))
    }
  }
  # Now, the other option: text
  if (!is.character(input)) {
    stop("Remember! Input must be a text vector or a data frame. Check ?input_handling for further indications. Notice that the error here is related to input_handling() function, not the function you may be calling. This function is an internal process that assures a standard handling of data across langstats.")
  }

  input <- input[!is.na(input)]
  if (length(input) == 0 || all(input == "")) {
    return(list(elements = character(), freqs = NULL))
  }

  # We proceed with the tokenization
  tokens <- tokenize(paste(input, collapse = " "))
  tokens <- tokens[tokens != ""]

  # Finally, we provide the standard input handling for texts too
  list(elements = tokens, freqs = NULL)
}
