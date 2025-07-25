% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zipf_heaps.R
\name{heaps}
\alias{heaps}
\title{Heaps' law calculation}
\usage{
heaps(input, level = c("word", "letter"), token = c("regex", "transformers"))
}
\arguments{
\item{input}{Text vector, whose elements can be phrases or documents, or data frame, for example, from the output of ngram(). Bear in mind that, as it has been defined, words must be on the first column! (Not anymore, input_handling() has acquired smart features!)}

\item{level}{As in other functions in langstats, allows the user to define the linguistic layer we aim to study, whether it is word, or letter.}

\item{token}{It declares the procedure used to extract the tokens, whether it is based on regex on neural BERT transformer model.}
}
\value{
data.frame with accumulated size, and quantity of unique words
}
\description{
Through this function we can estimate the growth of vocabulary with attention to the size of the corpus.
}
\examples{

# Example with a string (Euler, 1762)
text <- "there are persons determined to believe and admit nothing but what they see and touch"
heaps(text)

# Example with a dataset (heart_of_darkness, available in langstats, remember to load it with data(dataset_name))
data(heart_of_darkness)
heaps(heart_of_darkness)

#' @importFrom ggplot2 ggplot aes geom_point geom_col geom_text geom_line scale_x_log10 scale_y_log10 labs theme_minimal coord_flip

}
