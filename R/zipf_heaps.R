#' Zipf's law calculation
#'
#' This function grabs any input acceptable by input_handling() and returns a data frame with the words from the vector, and their frequencies and ranks.
#'
#'
#' @param input Text vector, whose elements can be phrases or documents, or data frame, for example, from the output of ngram(). Bear in mind that, as it has been defined, words must be on the first column! (Not anymore, input_handling() has acquired smart features!)
#' @param level As in other functions in langstats, allows the user to define the linguistic layer we aim to study, whether it is word, or letter.
#' @param token It declares the procedure used to extract the tokens, whether it is based on regex on neural BERT transformer model.
#'
#' @return data.frame Here the columns will be: (1) word, (2) frequency, (3) rank
#' @examples
#' # Example with a string (Boyle, 1673, found in Fisher (1935))
#'  text <- "I am very sorry, Pyrophilus, that to the many (elsewhere enumerated) difficulties which you may meet with, and must therefore surmount, in the serious and effectual prosecution of experimental philosophy I must add one discouragement more, which will perhaps as much surprise as dishearten you; and it is, that besides that you will find (as we elsewhere mention) many of the experiments published by authors, or related to you by the persons you converse with, false and unsuccessful (besides this, I say), you will meet with several observations and experiments which, though communicated for true by candid authors or undistrusted eye-witnesses, or perhaps recommended by your own experience, may, upon further trial, disappoint your expectation, either not at all succeeding constantly, or at least varying much from what you expected."
#' zipf(text)
#'
#' # Example with a dataset (selected_piantadosi, available in langstat, remember to load it with data(dataset_name))
#' data(selected_piantadosi)
#' zipf(selected_piantadosi)
#'
#' @export
zipf <- function(input, level = c("word", "letter"), token = c("regex", "transformers")) {
  level <- match.arg(level)
  token <- match.arg(token)

  # Use input_handling, standard function for the introduction of data into functions from langstats
  input <- input_handling(input, level = level)

  # We get from the unified treatment, first, the tokens
  elements <- input$elements

  # And then, the frequencies
  freq <- input$freqs

  # Sorting of counts
  freq_sorted <- sort(freq, decreasing = TRUE)

  # Finally, we build the data frame with the results from the Zipf report

  zipf_df <- data.frame(
    word = names(freq_sorted),
    frequency = as.integer(freq_sorted),
    rank = seq_along(freq_sorted)
  )

  zipf_df

}

#' Heaps' law calculation
#'
#' Through this function we can estimate the growth of vocabulary with attention to the size of the corpus.
#'
#' @param input Text vector, whose elements can be phrases or documents, or data frame, for example, from the output of ngram(). Bear in mind that, as it has been defined, words must be on the first column! (Not anymore, input_handling() has acquired smart features!)
#' @param level As in other functions in langstats, allows the user to define the linguistic layer we aim to study, whether it is word, or letter.
#' @param token It declares the procedure used to extract the tokens, whether it is based on regex on neural BERT transformer model.
#'
#' @return data.frame with accumulated size, and quantity of unique words
#' @examples
#'
#' # Example with a string (Euler, 1762)
#' text <- "there are persons determined to believe and admit nothing but what they see and touch"
#' heaps(text)
#'
#' # Example with a dataset (heart_of_darkness, available in langstats, remember to load it with data(dataset_name))
#' data(heart_of_darkness)
#' heaps(heart_of_darkness)
#'
#' @export
heaps <- function(input, level = c("word", "letter"),token = c("regex", "transformers")) {
  level <- match.arg(level)
  token <- match.arg(token)

  # Use input_handling, standard function for the introduction of data into functions from langstats
  input <- input_handling(input, level = level)

  # We get from the unified treatment, first, the tokens
  elements <- input$elements
  freq <- input$freqs

  # And then, the frequencies
  freq <- sort(table(elements), decreasing = TRUE)

  # Vocabulary growth calculation
  token_count <- seq_along(elements)
  vocab <- sapply(token_count, function(i) length(unique(elements[1:i])))

  # Building of the data frame
  df <- data.frame(
    tokens = token_count,
    vocabulary = vocab
  )
  df
}
