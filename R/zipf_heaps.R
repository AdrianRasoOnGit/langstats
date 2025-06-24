#' Zipf's law calculation
#'
#' This function grabs a text vector and returns a data frame with the words from the vector, and their frequencies and ranks.
#'
#'
#' @param text Text vector, whose elements can be phrases or documents. Note that both can be just a word
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
zipf <- function(text) {

  # Check if input is an actual text vector
  if (!is.character(text)) {
    stop("Remember! Input must be a text vector. Check ?zipf for further indications.")
  }
  text <- text[!is.na(text)]
  if (length(text) == 0 || all(text == "")) return(NA_real_)

  # Turn capital letters into lowercase and carry out tokenization
  words <- tolower(unlist(strsplit(text, "\\W+")))

  # Ignore empty tokens
  words <- words[words != ""]

  # Sort of frequencies in decreasing order
  freq <- sort(table(words), decreasing = TRUE)

  # Building of the data frame, with columns: (1) word, (2) frequency, (3) rank

  df <- data.frame( # data frame preparation
    word = names(freq),# first column, word
    frequency = as.integer(freq), # second column, frequency
    rank = seq_along(freq) # third column, rank
  )
  df
}

#' Heaps' law calculation
#'
#' Through this function we can estimate the growth of vocabulary with attention to the size of the corpus.
#'
#' @param text Text vector, whose elements can be phrases or documents. Note that both can be just a word
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
heaps <- function(text) {
  if (!is.character(text)) {

    # Check if input is an actual text vector
    stop("Remember! Input must be a text vector. Check ?heaps for further indications.")
  }
  text <- text[!is.na(text)]
  if (length(text) == 0 || all(text == "")) return(NA_real_)

  # Turn capital letters into lowercase and carry out tokenization
  words <- tolower(unlist(strsplit(text, "\\W+")))

  # Ignore empty tokens
  words <- words[words != ""]

  # Consideration of cummulative words in each state of the text
  total <- seq_along(words)
  vocab <- sapply(seq_along(words), function(i) length(unique(words[1:i])))

  # Building of the data frame
  data.frame(
    tokens = total,
    vocabulary = vocab
  )
}
