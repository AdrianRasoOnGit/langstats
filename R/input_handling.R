#' Input handling for functions of langstats: a smart and standard channel for inputs
#'
#' Through input_handling we can extract tokens and frequencies from a variety of input formats. At the moment, it is sensitive to texts, and data frames, the former being a common output in this package, so this standarisation of inputs can create a really smooth workflow. It detects automatically tokens and frequencies from data frames, and in the case of texts, it tokenises and calculates frequencies, providing a bag of words.
#'
#' @param input A text vector or a data frame, whether it comes from any function of langstats or any other origin
#' @param level It defines, as in many other functions here, the level of analysis required: it can be word or letter currently.
#' @param token It declares the procedure used to extract the tokens, whether it is based on regex on neural BERT transformer model.
#'
#' @return A list, which is performance attractive, with two elements: (1) elements, that are linguistic elements, and (2) frequencies, which can be found or calculated; if both of these are not possible, the index will be NULL
#' @details
#' When a data frame is provided, the function attempts to automatically detect a token column using common
#' names such as \code{"token"}, \code{"word"}, \code{"element"}, etc. If a frequency column named
#' \code{"frequency"} exists, it is normalized and returned. If only text is provided, the function tokenizes
#' using a regular expression based on the \code{level} argument, and completes the frequency index with a calculation on the frequencies of tokens. We plan to replace this search term procedure to a more functional one in next updates!
#'
#' @importFrom reticulate import

#'
#' @examples
#' text <- c("Codd is English", "Codd studied in Oxford", "Codd proposed the relational model in 1970")
#' input_handling(text, level = "word")
#'
#' df <- data.frame(word = c("model", "relational", "Codd"), frequency = c(10, 3, 2))
#' input_handling(df, level = "word")
#'
#' @keywords data_handling
#' @export
#'
input_handling <- function(input, level = c("word", "letter"), token = c("regex", "transformer")) {
  level <- match.arg(level)
  token <- match.arg(token)

  # Through reticulate, we load the BERT tokenizer
  get_tokenizer <- local({
    tokenizer <- NULL
    function() {
      if (is.null(tokenizer)) {
        if (!requireNamespace("reticulate", quietly = TRUE)) {
          stop("Caution! The 'reticulate' package is here required, in order to convey the transformer tokenisation. Please, consider installing it, or defaulting the tokenisation process to the regex-based alternative!")
        }
        transformers <- reticulate::import("transformers")
        tokenizer <<- transformers$AutoTokenizer$from_pretrained("bert-base-uncased")
      }
      tokenizer
    }
  })

  # Tokenization function using transformer for word level
  tokenize <- function(x) {
    x <- tolower(x)
    if (level == "letter") {
      return(unlist(strsplit(x, "")))
    }

    if (token == "regex") {
      return(unlist(strsplit(x, "\\W+")))
    }

    # Transformer tokenisation
    tokenizer_fn <- get_tokenizer()
    tokens <- tokenizer_fn$tokenize(x)
    unlist(tokens)
  }
    # Check if input is a data frame, and if that's the case, we lowercase columns names
    if (is.data.frame(input)) {
      colnames_lower <- tolower(names(input))

      # Search for tokens. We rely on a bit of clarity from the data frame format; luckily, every output from langstats works here
      candidates_token_cols <- c("token", "tokens", "element", "elements", "word", "words", "ngram", "ngrams")
      token_col_match <- intersect(colnames_lower, candidates_token_cols)

      # What if there are no matches? We will assume that the first column is related to words. For that, we add a warning: discretion is advised
      if (length(token_col_match) == 0) {
        token_col <- names(input)[1]
        warning("Discretion advised: no token column explicitly found! The function is assuming the first column contains the tokens. This column is called: '", token_col, "'. Is it a sound name? Proceeding in any case!")
      } else {
        token_col <- names(input)[match(token_col_match[1], colnames_lower)]
      }

      # We obtain now the contents of the column for tokens
      elements_raw <- as.character(input[[token_col]])
      elements_raw <- tolower(elements_raw)

      # Once we are finished with tokens, we can start with the search for frequencies. The procedure is the same
      candidates_freq_cols <- c("frequency", "freq", "count", "counts", "n", "n_tokens", "proportion")
      freq_col_match <- intersect(colnames_lower, candidates_freq_cols)

      if (length(freq_col_match) > 0) {
        freq_col <- names(input)[match(freq_col_match[1], colnames_lower)]
        raw_freqs <- input[[freq_col]]

        # Clean both token and frequency columns together
        valid <- !is.na(elements_raw) & !is.na(raw_freqs)
        elements <- elements_raw[valid]
        raw_freqs <- raw_freqs[valid]

        # Now, we apply a normalisation
        freqs <- raw_freqs
        names(freqs) <- elements
      } else {
        elements <- elements_raw[!is.na(elements_raw)]
        freqs <- NULL
      }

       # Let's add probabilities too, really useful for functions like shannon_entropy()
      probs <- freqs / sum(freqs)
      names(probs) <- names(freqs)

      return(list(elements = elements, freqs = freqs, probs = probs))
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

    # Time for the count
    freq_table <- table(tokens)
    freqs <- as.integer(freq_table)
    names(freqs) <- names(freq_table)

    # Let's add too probabilities, really useful for functions like shannon_entropy()
    probs <- freqs / sum(freqs)
    names(probs) <- names(freqs)

    # Finally, we provide the standard input handling for texts too
    list(elements = tokens, freqs = freqs, probs = probs)
  }
