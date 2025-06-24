#' Shannon's entropy or Shannon's information
#'
#' It calculates Shannon's entropy of a linguistic element such as word or letter, provided a sample space ("text").
#'
#' @param text Text vector, whose elements can be phrases or texts
#' @param level "word" o "letter"
#' @return Entropy in bits
#' @examples
#' # Example of entropy of words from Shannon's paper "The bandwagon" ()
#' text1 <- "Information theory has, in the last few years, become something of a scientific bandwagon. Starting as a technical tool for the communication engineer, it has received an extraordinary amount of publicity in the popular as well as the scientific press. In part, this has been due to connections with such fashionable fields as computing machines, cybernetics, and automation; and in part, to the novelty of its subject matter. As a consequence, it has perhaps been ballooned to an importance beyond its actual accomplishments. Our fellow scientists in many different fields, attracted by the fanfare and by the new avenues opened to scientific analysis, are using these ideas in their own problems. Applications are being made to biology, psychology, linguistics, fundamental physics, economics, the theory of organization, and many others. In short, information theory is currently partaking of a somewhat heady draught of general popularity. Although this wave of popularity is certainly pleasant and exciting for those of us working in the field, it carries at the same time an element of danger. While we feel that information theory is indeed a valuable tool in providing fundamental insights into the nature of communication problems and will continue to grow in importance, it is certainly no panacea for the communication engineer or, a fortiori, for anyone else. Seldom do more than a few of nature's secrets give way at one time. It will be all too easy for our somewhat artificial prosperity to collapse overnight when it is realized that the use of a few exciting words like information, entropy, redundancy, do not solve all our problems. What can be done to inject a note of moderation in this situation? In the first place, workers in other fields should realize that the basic results of the subject are aimed in a very specific direction, a direction that is not necessarily relevant to such fields as psychology, economics, and other social sciences. Indeed, the hard core of information theory is, essentially, a branch of mathematics, a strictly deductive system. A thorough understanding of the mathematical foundation and its communication application is surely a prerequisite to other applications. I personally believe that many of the concepts of information theory will prove useful in these other fields - and, indeed, some results are already quite promising - but the establishing of such applications is not a trivial matter of translating words to a new domain, but rather the slow tedious process of hypothesis and experimental verification. If, for example, the human being acts in some situations like an ideal decoder, this is an experimental and not a mathematical fact, and as such must be tested under a wide variety of experimental situations."
#' shannon_entropy(text1, level = "word")
#'
#' # Example of entropy of letters in alphabet (Shannon and Weaver, 1948)
#' text2 <- "a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u v, w, x, y, z"
#' shannon_entropy(text2, level = "letter")
#'
#' @export

shannon_entropy <- function(text, level = c("word", "letter")) {
  level <- match.arg(level)

  # Check if the input is an actual text vector
  if (!is.character(text)) stop("Remember! Input must be a text vector. Check ?shannon_entropy for further indications.")
  text <- text[!is.na(text)]
  if (length(text) == 0 || all(text == "")) return(NA_real_)

  # Turn capital letters into lowercase
  elements <- tolower(text) # Turn capital letters into lowercase

  if (level == "word") {
   # Tokenization of words
    elements <- unlist(strsplit(elements, "\\W+"))
   # Tokenization of letters
  } else {
    elements <- unlist(strsplit(elements, ""))
  }

  # Ignore null elements
  elements <- elements[elements != ""]

  # Obtain frequencies
  freqs <- table(elements) / length(elements)

  # Shannon's entropy formula
  -sum(freqs * log2(freqs))
}

#' Cross entropy between texts
#'
#' It calculates the cross entropy (that is, H(P, Q), where P is the local distribution (text_p) and Q is a global distribution
#'
#' @param text_p local text
#' @param text_q global text, or reference
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

  # Check if the input is an actual text vector
  if (!is.character(text_p) || !is.character(text_q)) {
    stop("Remember! Input text_p and text_q must be both a text vector. Check ?cross_entropy for further indications.")
  }


  cleanse <- function(text, level) {
    # Tokenization of words
    if (level == "word") {
      unlist(strsplit(tolower(text), "\\W+"))
    # Tokenization of letters
    } else {
      unlist(strsplit(tolower(text), ""))
    }
  }

  # Cleaning of both local and global sources
  elems1 <- cleanse(text_p, level)
  elems2 <- cleanse(text_q, level)

  # Ignore null elements in both local and global tables
  elems1 <- elems1[elems1 != ""]
  elems2 <- elems2[elems2 != ""]

  # Definition of local and global probabilities
  p <- table(elems1) / length(elems1)
  q <- table(elems2) / length(elems2)

  # We assure that every word in P is in Q
  words <- names(p)
  q <- q[words]

  # Apply epsilon smoothing so we avoid log(0)
  q[is.na(q)] <- 1e-10

  # Cross entropy formula
  -sum(p * log2(q))
}

#' Information gain between two texts
#'
#' Here we try to measure how much information we obtain from one state of the source and another, which is really useful in classification and in general in information theory apply to language projects
#'
#' @param text_p Local source
#' @param text_q Global source
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
#'
#'
#' gain(selected_piantadosi, heart_of_darkness, level = "word")
#'
#'
#' @export
gain <- function(text_p, text_q, level = c("word", "letter")) {level <- match.arg(level)
  # Check if the input is an actual text vector
  if (!is.character(text_p) || !is.character(text_q)) {
    stop("Remember! Input text_p and text_q must be both a text vector. Check ?gain for further indications.")
  }
  # Calculate both Shannon's entropy and cross entropy
  h_p <- shannon_entropy(text_p, level)
  h_pq <- cross_entropy(text_p, text_q, level)

  # Information gain wrapped formula
  h_p - h_pq
}
