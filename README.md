langstats; An out-of-the-box environment for statistical language
analysis
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Pre-Release](https://img.shields.io/github/v/release/adrianrasoongit/langstats?include_prereleases)](https://github.com/AdrianRasoOnGit/langstats/releases)
[![R-CMD-check](https://github.com/AdrianRasoOnGit/langstats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AdrianRasoOnGit/langstats/actions)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
<!-- badges: end -->

## Brief description

`langstats` is an R package designed to help language researchers
explore the statistical properties of natural language in an accessible
and agile way. It provides a set of functions tailored for extracting
relevant information in quantitative linguistic analysis, such as Zipf’s
law, Heaps’ law, the Zipf-Mandelbrot adjustment, and key
information-theoretic measures like Shannon entropy, cross entropy, and
information gain.

This package aims to bring these tools—often complex to interpret—closer
to language specialists. At the same time, it proposes a toolkit that
allows researchers to apply the foundational concepts of this tradition
directly, within a single environment, without needing to implement the
required models manually. It offers a flexible and practical suite of
functions that are designed to adapt, through their parameters and
general structure, to a wide range of projects.

In the current version *(remember to check the [official
repository](github.com/AdrianRasoOnGit/langstats) to confirm whether you
are using the latest version!)*, the package includes the following
functions:

------------------------------------------------------------------------

- **Zipf’s law** (`zipf(input, level)`):  
  Expresses a power-law relationship between the frequency of a word and
  its rank in the corpus. According to Zipf’s law, the most frequent
  word appears about twice as often as the second most frequent word,
  three times as often as the third, and so on.

- **Heaps’ law** (`heaps(input, level)`):  
  Estimates vocabulary growth based on the number of unique words found
  in a corpus. The relationship is typically expressed as
  $V(N) = K N^\beta$, where $V$ is the vocabulary size and $N$ is the
  number of tokens.

- **Zipf-Mandelbrot’s law** (`zipf_mandelbrot(input)`):  
  A refinement of Zipf’s law proposed by Mandelbrot (1955) that better
  models the frequency of low-rank (often grammatical) terms. It adds
  two parameters: a rank offset $\beta$, and a scaling constant $C$,
  resulting in a more flexible power-law model.

- **Shannon’s entropy** (`shannon_entropy(input, level)`):  
  Quantifies the average uncertainty or information contained in a
  linguistic unit (word or letter), based on its distribution. This
  metric is computed using:  
  $$
  H(X) = -\sum p(x) \log_2 p(x)
  $$  
  The function allows analysis at either the word or letter level via
  the `level` parameter.

- **Cross entropy** (`cross_entropy(text_p, text_q, level)`):  
  Measures the discrepancy between two probability distributions: one
  empirical and one modeled. It represents how much additional
  information is needed to encode data from one distribution using
  another—commonly used to evaluate language models.

- **Information gain** (`gain(text_p, text_q, level)`):  
  Defined as the difference between the actual entropy and the cross
  entropy: $IG = H(P) - H(P, Q)$. It quantifies how much more
  informative a model is relative to a reference distribution.

- **Bag of Words generator** (`bow(text, level)`):  
  A bag of words is a standard NLP object that tallies the frequency of
  tokens in a text. This function returns a `data.frame` with each
  token, its absolute count, and its relative proportion.

- **N-grams** (`ngrams(input, level)`): With this function, we can
  produce n-grams that capture the combinatorial situation of the
  elements in the text, considering different degrees of grouping
  through the parameter n, which will be an integer representing the
  number of elements grouped in the n-gram.

- **$G^2$ lexical co-ocurrence test
  (`collocation_g2(input, word1(optional), word2(optional))`)**: It
  performs a log-likelihood ratio test (that is, a $G^2$ test), with the
  purpose of unveiling significant collocation patterns in lexical
  distributions. When word1 and word2 are given, the $G^2$ test is
  performed on both words through a contingency table (that can be
  accessed!), and if they are not provided, `g2()` will show the most
  significant collocation structures in the input.

- **$G^2$ test and contingency tables (`g2(input)`) **: It performs a
  log-likelihood ratio test (that is, a $G^2$ test), that it is called
  from other functions. This is an internal quite straightforward
  function in the package, it’s real use can be found in
  `collocation_g2()`, which supports this very function.

- **Term frequency and inverse document frequency** (`tf(input)`,
  `idf(input)`, `tf_idf(input)`):  
  With these three functions users are able to gain insight on lexical
  distributions with a quite standard and enlightening measure: TF-IDF —
  not to be confused with other IDFs, whose systematic violence and
  repression bear no resemblance to Inverse Document Frequencies
  (luckily!). `tf()` computes the frequency of each token within
  individual documents. `idf()` captures how rare a token is across all
  documents in the corpus, using the formula  
  $$
  \text{idf}(t) = \log\left(\frac{N}{n_t}\right)
  $$  
  where $N$ is the total number of documents and $n_t$ is the number of
  documents that contain term $t$. Finally, `tf_idf()` combines the two
  measures to emphasize terms that are both frequent in a specific
  document and relatively rare in the corpus:  
  $$
  \text{tf\_idf}(t, d) = \text{tf}(t, d) \times \text{idf}(t)
  $$

Since `langstats v0.2.0`, the package comes with an internal function
that forces an unified treatment of inputs. That function is named,
quite in a straightforward way, `input_handling()`. This is of no real
use for the user, as it is pretty internal, but out of transparency I
mention it here.

- **Input handling** (`input_handling(input)`): Given a text or a data
  frame, it detects or calculates frequencies from tokens and also
  probability values. These are relevant data for the functions of the
  package and are obtained and stored in a universal manner, so errors
  and implementations are swifter and safer. It returns a list, which is
  way faster than a data frame to manipulate. The readability that we
  lose with the list is trivial, since that list will be of internal use
  and the user will always have at hand a data frame output to assess
  the data and results. Since the version `v0.4.0`, the function offers
  a BERT-powered tokeniser, that can be accessed through the argument
  `token = c("regex", "transformers")`. If not defined,
  `input_handling()` selects the regex based tokeniser of previous
  versions, which is usually faster and still satisfactory most of the
  times.

Also, since `langstats v0.5.0`, the package allows its users to
automatically plot results with a smart plot function powered by
`ggplot2`. We introduce it below:

- **Plotting with automated configuration** (`plot_ls(input)`): This
  function automatically plot results regardless of the origin of the
  data, as long as it has been returned from a native function of
  `langstats`.

  Besides, the package comes with some example data to try the features
  of this resource. Remember to type `data(“name_of_the_data_here”)`
  before using it! The datasets provided are:

- **Piantadosi Selected Papers** (named: `selected_piantadosi`): A brief
  collection of five papers of psychologist Steven T. Piantadosi,
  gathered in his personal website
  (<https://colala.berkeley.edu/people/piantadosi/>).

- **Heart of Darkness** (named: `heart_of_darkness`): The whole Joseph
  Conrad’s novel. Ideal to try the functions of the package.

  In the following sections of this README, we will show how to install
  the package, and how to use it. For further details, you can always
  run `?function_name` in your R console, or visit our site on
  [GitHub](github.com/AdrianRasoOnGit/langstats).

------------------------------------------------------------------------

## Installation

You can install the actual version of langstats like so:

``` r
# Install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("AdrianRasoOnGit/langstats")
```

## Examples

Here we share just a pair of examples on how a project can benefit from
the functions `langstats` provides. Remember to check the file
`A Brief Overview of langstats` if you’d like to dig a bit deeper on use
cases of the package.

### Example 1. Report on potential laws in a text

We can study the main potential statistical laws in `langstats` using
`zipf()` and `heaps()` and produce reports aimed at examining a
particular text, like we show below:

``` r
# Load langstats package and load the dataset, here heart_of_darkness, included in langstats
library(langstats)
data("heart_of_darkness")

# Preparation of both Zipf and Heaps report
zipf_report <- zipf(heart_of_darkness)
heaps_report <- heaps(heart_of_darkness)

# Show some results of the function in data frame form. For Heaps, we look at a narrow window later in text, to showcase more clearly the effect of the law
head(zipf_report, 10)
subset(heaps_report, tokens >= 1000 & tokens <= 1010)
```

The output should look like this:

    ##    word frequency rank
    ## 1   the      2292    1
    ## 2    of      1374    2
    ## 3     a      1153    3
    ## 4     i      1153    4
    ## 5   and       993    5
    ## 6    to       896    6
    ## 7   was       671    7
    ## 8    in       617    8
    ## 9    he       593    9
    ## 10  had       506   10

    ##      tokens vocabulary
    ## 1000   1000        472
    ## 1001   1001        472
    ## 1002   1002        472
    ## 1003   1003        472
    ## 1004   1004        472
    ## 1005   1005        472
    ## 1006   1006        472
    ## 1007   1007        472
    ## 1008   1008        472
    ## 1009   1009        472
    ## 1010   1010        472

We can (and should) summarise these results in a graph of the following
form, through `ggplot2`:
![](README_files/figure-gfm/zipf_heaps_report_example_plot-1.png)<!-- -->![](README_files/figure-gfm/zipf_heaps_report_example_plot-2.png)<!-- -->

This way we can apply `zipf()` and `heaps()` in a report of the sort
here described.

### Example 2. Information Theory exploratory study in a corpus

We will examine now `selected_piantadosi` dataset, which is a corpus
constituted by five papers of Steven T. Piantadosi. We plan to obtain
its main information theory measures and compare it to
`heart_of_darkness`:

``` r
library(langstats)
data("selected_piantadosi")
data("heart_of_darkness")

# We calculate Shannon's entropy at word level
shannon_entropy(selected_piantadosi, level = "word")

# We calculate cross entropy at word level between selected_piantadosi and heart_of_darkness
cross_entropy(selected_piantadosi, heart_of_darkness, level = "word")

# We finally study the information gain between these two sources, again, at word level
gain(selected_piantadosi, heart_of_darkness, level = "word")
```

Now, let’s see the results:

    ## Shannon entropy is  10.13449

    ## Cross entropy is  20.10682

    ## Information gain is  -9.972331

That’s how we can implement these functions in a information theoretic
project aimed at linguistic data.

------------------------------------------------------------------------

Any piece of advice and any sort of suggestion are more than welcome.
This is an ongoing project, and I’d like to add many other functions and
features to the package. For contact, please reach my institutional
email address (<adrraso@ucm.es>).

Thanks for using `langstats`. Have a wonderful analysis!
