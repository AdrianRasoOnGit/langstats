#' Term Frequency (TF)
#'
#' Through \code{tf()}, we compute the term frequency (TF) of linguistic elements across documents or structured input tables. This function leverages \code{input_handling()} to standardise various formats of text and data, making it fully compatible with the langstats pipeline.
#'
#' If the input is a character vector, it is interpreted as a collection of documents. Each element will be tokenised (depending on the level and token method) and a frequency table will be created for each. If a data frame is passed, it is parsed to extract already available token-frequency information.
#'
#' @param input A text vector or a data frame, either raw text or a tidy token-frequency structure from this package or another source
#' @param level The level of analysis: currently accepts \code{"word"} or \code{"letter"}
#' @param token The method for token extraction: a \code{"regex"}-based approach or a neural \code{"transformer"} model (BERT)
#'
#' @return A data frame with the following structure: \code{document}The numeric index of the document. \code{term} The token basically. \code{tf} The frequency of that term within the document (the count!).
#' }
#'
#' @details
#' Internally, this function makes use of \code{input_handling()} to support both raw and pre-processed inputs. It identifies tokens and their associated frequencies for each document or input unit. For text inputs, a bag-of-words representation is constructed. For data frames, it identifies the most probable token and frequency columns. The function ensures lowercasing and normalization where applicable.
#'
#' This function is useful when term-level distribution is needed as a basis for more complex calculations, such as inverse document frequency (see \code{idf()}) or full tf-idf scores (see \code{tf_idf()}).
#'
#' @seealso \code{\link{input_handling}}, \code{\link{idf}}, \code{\link{tf_idf}}
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
#' The function \code{idf()} calculates the inverse document frequency (IDF) for each linguistic element (token or character) across a collection of documents. The IDF metric helps to quantify how unique or informative a term is, relative to its distribution in the entire corpus.
#'
#' It takes as input either raw texts or data frames already containing token-frequency information. Behind the scenes, it reuses \code{input_handling()} to extract or verify the tokens per document and then computes document frequency counts before applying the standard IDF formula.
#'
#' @param input A text vector (multiple documents), or a data frame of tokens and frequencies
#' @param level The level of linguistic analysis: can be \code{"word"} or \code{"letter"}
#' @param token The tokenisation method: either \code{"regex"} or \code{"transformer"} (BERT-based)
#'
#' @return A data frame with the following columns: \code{term} The token, basically.
#'   \code{{idf} The inverse document frequency score, calculated as \code{log(n_documents / document_frequency)} (as usual).
#' }
#'
#' @details
#' The IDF score increases with term rarity across documents. Terms appearing in every document will have an IDF of zero, while terms unique to one document will have the highest scores.
#' This function forms the second step in a classic TF-IDF pipeline. It is most effective when used alongside \code{tf()} or directly within \code{tf_idf()}.
#'
#' Like other core functions in langstats, this tool is robust to multiple input formats and automatically processes text or table-based inputs.
#'
#' @seealso \code{\link{tf}}, \code{\link{tf_idf}}, \code{\link{input_handling}}
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
#' The function \code{tf_idf()} calculates the TF-IDF score for each linguistic element across a set of documents. It combines two key components: term frequency (TF) and inverse document frequency (IDF), producing a score that reflects both the importance of a term within a document and its uniqueness across the full corpus.
#'
#' This function supports both raw text and structured token-frequency data frames, ensuring compatibility with the broader langstats pipeline. Internally, it delegates preprocessing to \code{input_handling()}, followed by calls to \code{tf()} and \code{idf()} to extract the necessary components for TF-IDF calculation.
#'
#' @param input A vector of character strings (one per document), or a data frame of tokens and their frequencies
#' @param level The level of linguistic granularity: currently supports \code{"word"} or \code{"letter"}
#' @param token The method for tokenisation: either \code{"regex"} (basic pattern matching) or \code{"transformer"} (BERT-based tokenisation)
#'
#' @return A data frame with the following columns: (1) document, (2) term, (3) tf, (4) idf, and (5) tf_idf
#'
#' @details
#' TF-IDF is widely used in information retrieval and NLP tasks to highlight terms that are both frequent in a document and rare across the corpus. Common stopwords typically have low TF-IDF scores, while distinctive terms rank higher.
#'
#' This function ensures smooth integration with the langstats toolkit by automatically adapting to text vectors or data frames and applying consistent token and frequency handling through \code{input_handling()}.
#'
#' @seealso \code{\link{tf}}, \code{\link{idf}}, \code{\link{input_handling}}
#'
#' @examples
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
