#' Shannon's entropy
#'
#' It calculates Shannon's entropy of a linguistic element such as word or letter, provided a sample space ("text").
#'
#' @param input Text vector, whose elements can be phrases or documents, or data frame, for example, from the output of ngram(). Bear in mind that, as it has been defined, words must be on the first column! (Not anymore, input_handling() has acquired smart features!)
#' @param level "word" or "letter"
#' @return Entropy in bits
#' @examples
#' # Example of entropy of words from Shannon's paper "The bandwagon" (Shannon, 1953)
#' text1 <- "Information theory has, in the last few years, become something of a scientific bandwagon. Starting as a technical tool for the communication engineer, it has received an extraordinary amount of publicity in the popular as well as the scientific press. In part, this has been due to connections with such fashionable fields as computing machines, cybernetics, and automation; and in part, to the novelty of its subject matter. As a consequence, it has perhaps been ballooned to an importance beyond its actual accomplishments. Our fellow scientists in many different fields, attracted by the fanfare and by the new avenues opened to scientific analysis, are using these ideas in their own problems. Applications are being made to biology, psychology, linguistics, fundamental physics, economics, the theory of organization, and many others. In short, information theory is currently partaking of a somewhat heady draught of general popularity. Although this wave of popularity is certainly pleasant and exciting for those of us working in the field, it carries at the same time an element of danger. While we feel that information theory is indeed a valuable tool in providing fundamental insights into the nature of communication problems and will continue to grow in importance, it is certainly no panacea for the communication engineer or, a fortiori, for anyone else. Seldom do more than a few of nature's secrets give way at one time. It will be all too easy for our somewhat artificial prosperity to collapse overnight when it is realized that the use of a few exciting words like information, entropy, redundancy, do not solve all our problems. What can be done to inject a note of moderation in this situation? In the first place, workers in other fields should realize that the basic results of the subject are aimed in a very specific direction, a direction that is not necessarily relevant to such fields as psychology, economics, and other social sciences. Indeed, the hard core of information theory is, essentially, a branch of mathematics, a strictly deductive system. A thorough understanding of the mathematical foundation and its communication application is surely a prerequisite to other applications. I personally believe that many of the concepts of information theory will prove useful in these other fields - and, indeed, some results are already quite promising - but the establishing of such applications is not a trivial matter of translating words to a new domain, but rather the slow tedious process of hypothesis and experimental verification. If, for example, the human being acts in some situations like an ideal decoder, this is an experimental and not a mathematical fact, and as such must be tested under a wide variety of experimental situations."
#' shannon_entropy(text1, level = "word")
#'
#' # Example of entropy of letters in alphabet (Shannon and Weaver, 1948)
#' text2 <- "a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u v, w, x, y, z"
#' shannon_entropy(text2, level = "letter")
#'
#' @export

shannon_entropy <- function(input, level = c("word", "letter")) {
  level <- match.arg(level)

  # input_handling()! We handle the data introduced in a standard way
  input <- input_handling(input, level = level)

  # We extract from the data frame that outputs input_handling() tokens and probabilities
  elements <- input$elements
  probs <- input$probs

  # Shannon entropy formula
   return(-sum(probs * log2(probs)))
  }


#' Cross entropy between texts
#'
#' It calculates the cross entropy (that is, H(P, Q), where P is the local distribution (text_p) and Q is a global distribution
#'
#' @param text_p local text, or local data frame
#' @param text_q global text, or local data frame
#' @param level "word" or "letter"
#' @return Cross entropy in bits
#' @examples
#' # Example of comparison between two texts on word level (Shannon, 1939)
#' text1 <- "Dear Dr. Bush, Off and on I have been working on an analysis of some of the fundamental properties of general systems for the transmission of intelligence, including telephony, radio, television, telegraphy, etc."
#' text2 <- "Of course, my main project is still the machine for performing symbolic mathematical operations; although I have made some progress in various outskirts of the problem I am still pretty much in the woods, so far as actual results are concerned and so can't tell you much about it. I have a set of circuits drawn up which actually will perform symbolic differentiation and integration on most functions, but the method is not quite general or natural enough to be perfectly satisfactory. Some of the general philosophy underlying the machine seems to evade me completely..."
#' cross_entropy(text1, text2, level = "word")
#'
#' # Example of comparison between two datasets (selected_piantadosi and heart_of_darkness, available in langstats, remember to load them with data(dataset_name))
#' data(selected_piantadosi)
#' data(heart_of_darkness)
#'
#'
#' cross_entropy(selected_piantadosi, heart_of_darkness, level = "word")
#'
#' @export
#'
cross_entropy <- function(text_p, text_q, level = c("word", "letter")) {
  level <- match.arg(level)

  # Use input_handling to standardize both sources
  input_p <- input_handling(text_p, level = level)
  input_q <- input_handling(text_q, level = level)

  # We grab the probabilities from the local (p) and global (q) source
  p <- input_p$probs
  q <- input_q$probs

  # We want to assure we have achieved traceability in the input_handling function, so let's check if we have an actual vector of tokens and values
  if(is.null(names(p))) names (p) <- input_p$elements
  if(is.null(names(q))) names(q) <- input_q$elements

  # We now align the vocab from both sources
  words <- names(p)
  q <- q[words]
  q[is.na(q)] <- 1e-10

  # Finally, we get to apply the cross entropy formula
  -sum(p * log2(q))
}

#' Information gain between two texts
#'
#' Here we try to measure how much information we obtain from one state of the source and another, which is really useful in classification and in general in information theory apply to language projects
#'
#' @param text_p Local source, can be an actual text, or a data frame
#' @param text_q Global source, can be an actual text, or a data frame
#' @param level "word" or "letter"
#' @return Gained information bits, that is: (H(P) - H(P,Q))
#' @examples
#' # Example of information gain from two texts (Shannon, 1939)
#' text1 <- "Dear Dr. Bush, Off and on I have been working on an analysis of some of the fundamental properties of general systems for the transmission of intelligence, including telephony, radio, television, telegraphy, etc."
#' text2 <- "Of course, my main project is still the machine for performing symbolic mathematical operations; although I have made some progress in various outskirts of the problem I am still pretty much in the woods, so far as actual results are concerned and so can't tell you much about it. I have a set of circuits drawn up which actually will perform symbolic differentiation and integration on most functions, but the method is not quite general or natural enough to be perfectly satisfactory. Some of the general philosophy underlying the machine seems to evade me completely..."
#' gain(text1, text2, level = "word")
#'
#' # Example of comparison between two datasets (selected_piantadosi and heart_of_darkness, available in langstats, remember to load them with data(dataset_name))
#' data(selected_piantadosi)
#' data(heart_of_darkness)
#' gain(selected_piantadosi, heart_of_darkness, level = "word")
#'
#'
#' @export
gain <- function(text_p, text_q, level = c("word", "letter")) {level <- match.arg(level)

  # Standardize inputs
  input_p <- input_handling(text_p, level = level)
  input_q <- input_handling(text_q, level = level)

  # Let's extract probabilities from the standard handling of data
  p <- input_p$probs
  q <- input_q$probs

  # Just in case, we are going to check if names exist
  if(is.null(names(p))) names(p) <- input_p$elements
  if(is.null(names(q))) names(q) <- input_q$elements

  # We are now ready to align both vocabularies
  words <- names(p)
  q <- q[words]
  q[is.na(q)] <- 1e-10

  # Obtain entropy and cross entropy. Required for information gain!
  entropy_p <- -sum(p * log2(p))
  cross_entropy_pq <- -sum(p * log2(q))

  # Finally, we get to evaluate the information gain
  entropy_p - cross_entropy_pq
}
