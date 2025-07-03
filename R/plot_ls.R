#' Smart Plotting Function for langstats Objects
#'
#' Automatically detects the type of langstats object and plots accordingly.
#'
#' @param x A data frame object returned by langstats functions like zipf(), heaps(), ngrams(), collocation_g2()
#' @param top_n Integer. How many top items to plot for frequency-based tables
#' @param ... Additional arguments (not used yet)
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_col geom_text scale_x_log10 scale_y_log10 labs theme_minimal coord_flip
#'
#' @return A ggplot2 plot
#' @export
plot_ls <- function(x, top_n = 30, ...) {
  stopifnot(is.data.frame(x))

  names_lower <- tolower(names(x))

  if (all(c("word", "frequency", "rank") %in% names_lower)) {
    # Zipf function graph [zipf()]
    ggplot(x, aes(rank, frequency)) +
      geom_point(alpha = 0.6, color = "steelblue") +
      scale_x_log10() + scale_y_log10() +
      labs(title = "Zipf's Law", x = "Rank (log)", y = "Frequency (log)")
  }

  else if (all(c("tokens", "vocabulary") %in% names_lower)) {
    # Heaps function graph [heaps()]
    ggplot(x, aes(tokens, vocabulary)) +
      geom_line(color = "darkgreen", size = 1) +
      scale_x_log10() + scale_y_log10() +
      labs(title = "Heaps' Law", x = "Tokens (log)", y = "Vocabulary (log)")
  }

  else if (all(c("ngram", "frequency") %in% names_lower)) {
    # Ngram function graph [ngrams()]
    df <- head(x[order(-x$frequency), ], top_n)
    ggplot(df, aes(reorder(ngram, frequency), frequency)) +
      geom_col(fill = "purple") +
      coord_flip() +
      labs(title = paste("Top", nrow(df), "N-grams"), x = NULL, y = "Frequency")
  }

  else if (all(c("ngram", "g2", "p_value") %in% names_lower)) {
    # G^2 collocation function graph [g2_co-ocurrence_test()]
    df <- head(x[order(-x$G2), ], top_n)
    ggplot(df, aes(reorder(ngram, G2), G2)) +
      geom_col(fill = "firebrick") +
      coord_flip() +
      labs(title = paste("Top", nrow(df), "Collocations (G^2)"),
           x = NULL, y = expression(G^2))
  }

  else if (is.numeric(x) && length(x) == 1) {
    # Information theory functions graph
    df <- data.frame(label = "Value", value = x)
    return(
      ggplot(df, aes(label, value)) +
        geom_col(fill = "dodgerblue") +
        geom_text(aes(label = round(value, 3)), vjust = -0.5, size = 6) +
        ylim(0, x * 1.1) +
        labs(title = "Information Measure", x = "", y = "Bits") +
        theme_minimal()
    )
  }


  else {
    stop("Sorry, plot_ls() doesn't recognize this object. Did it come from a langstats function?")
  }
}
