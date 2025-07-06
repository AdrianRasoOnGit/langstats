#' Term Frequency (TF)
#'
#' Through  we compute the term frequency (TF) of linguistic elements across documents or structured input tables. This function leverages
#'
#' If the input is a character vector, it is interpreted as a collection of documents. Each element will be tokenised (depending on the level and token method) and a frequency table will be created for each. If a data frame is passed, it is parsed to extract already available token-frequency information.
#'
#' @param input A text vector or a data frame, either raw text or a tidy token-frequency structure from this package or another source
#' @param level The level of analysis: currently accepts "word" or "letter"
#' @param token The method for token extraction: a "regex"-based approach or a neural "transformer" model (BERT)
#'
#' @return A data frame with the following structure
#'

#'
#' @examples
#' text <- c("Codd is English", "Codd studied in Oxford", "Codd proposed the relational model in 1970")
#' tf(text, level = "word")
#'
#' df <- data.frame(word = c("model", "relational", "Codd"), frequency = c(10, 3, 2))
#' tf(df, level = "word")
#'
#' @export

tf <- function(input, level = c("word", "letter"), token = c("regex", "transformer")) {
  level <- match.arg(level)
  token <- match.arg(token)

  if (is.character(input)) {
    docs <- input
    tf_list <- lapply(seq_along(docs), function(i) {
      result <- input_handling(docs[i], level = level, token = token)
      if (is.null(result$freqs)) return(NULL)
      data.frame(document = i,
                 term = names(result$freqs),
                 tf = as.numeric(result$freqs),
                 stringsAsFactors = FALSE)
    })
    tf_df <- do.call(rbind, tf_list)
  } else if (is.data.frame(input)) {
    result <- input_handling(input, level = level, token = token)
    if (is.null(result$freqs)) stop("No frequencies found in data frame input.")
    tf_df <- data.frame(document = 1,
                        term = result$elements,
                        tf = as.numeric(result$freqs),
                        stringsAsFactors = FALSE)
  } else {
    stop("Input must be a character vector or a data frame.")
  }

  tf_df <- tf_df[!is.na(tf_df$term) & tf_df$term != "", ]
  return(tf_df)
}

#' Inverse Document Frequency (IDF): measuring informational uniqueness
#'
#' The function  calculates the inverse document frequency (IDF) for each linguistic element (token or character) across a collection of documents. The IDF metric helps to quantify how unique or informative a term is, relative to its distribution in the entire corpus.
#'
#'
#' @param input A text vector (multiple documents), or a data frame of tokens and frequencies
#' @param level The level of linguistic analysis:
#' @param token The tokenisation method: either  (BERT-based)
#'
#' @return A data frame with the following columns:
#'
#' @examples
#' text <- c("Codd is English", "Codd studied in Oxford", "Codd proposed the relational model in 1970")
#' idf(text, level = "word")
#'
#' df <- data.frame(word = c("model", "relational", "Codd"), frequency = c(10, 3, 2))
#' idf(df, level = "word")
#'
#' @export
#'
idf <- function(input, level = c("word", "letter"), token = c("regex", "transformer")) {
  tf_df <- tf(input, level = level, token = token)

  df_counts <- aggregate(document ~ term, data = tf_df, FUN = function(x) length(unique(x)))
  colnames(df_counts)[2] <- "df"
  n_docs <- length(unique(tf_df$document))

  df_counts$idf <- log(n_docs / df_counts$df)
  return(df_counts[, c("term", "idf")])
}

#' TF-IDF: Term Frequency–Inverse Document Frequency
#'
#' The function  calculates the TF-IDF score for each linguistic element across a set of documents. It combines two key components: term frequency (TF) and inverse document frequency (IDF), producing a score that reflects both the importance of a term within a document and its uniqueness across the full corpus.
#'
#'
#' @param input A vector of character strings (one per document), or a data frame of tokens and their frequencies
#' @param level The level of linguistic granularity:
#' @param token The method for tokenisation
#'
#' @return A data frame with the following columns: (1) document, (2) term, (3) tf, (4) idf, and (5) tf_idf
#'
#' texts <- c("Codd is English", "Codd studied in Oxford", "Codd proposed the relational model in 1970")
#' tf_idf(texts, level = "word")
#'
#' df <- data.frame(word = c("model", "relational", "Codd"), frequency = c(10, 3, 2))
#' tf_idf(df, level = "word")
#'
#' @export
#'
#'
#' @return A data frame with columns: document, term, tf, idf, tf_idf
#' @export
#'
tf_idf <- function(input, level = c("word", "letter"), token = c("regex", "transformer")) {
  tf_df <- tf(input, level = level, token = token)
  idf_df <- idf(input, level = level, token = token)

  merged <- merge(tf_df, idf_df, by = "term")
  merged$tf_idf <- merged$tf * merged$idf

  merged <- merged[order(merged$document, -merged$tf_idf), ]
  rownames(merged) <- NULL
  return(merged)
}
