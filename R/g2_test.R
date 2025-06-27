#' G² (Likelihood Ratio) Test for Independence
#'
#' Computes the G² statistic for a 2×2 contingency table. Often used to measure association strength between word co-occurrences.
#'
#' @param observed A 2×2 matrix of observed frequencies.
#'
#' @return A list with the G² statistic, degrees of freedom, p-value, and expected frequencies.
#' @examples
#' mat <- matrix(c(30, 70, 20, 880), nrow = 2, byrow = TRUE)
#' g2(mat)
#' @export
g2 <- function(observed) {
  if (!all(dim(observed) == c(2, 2))) {
    stop("Input must be a 2x2 matrix.")
  }

  total <- sum(observed)
  row_totals <- rowSums(observed)
  col_totals <- colSums(observed)
  expected <- outer(row_totals, col_totals) / total

  # Avoid log(0) with masking
  g2_stat <- 2 * sum(ifelse(observed == 0, 0, observed * log(observed / expected)))

  df <- (nrow(observed) - 1) * (ncol(observed) - 1)
  p_value <- 1 - pchisq(g2_stat, df)

  list(
    G2 = g2_stat,
    df = df,
    p_value = p_value,
    expected = expected
  )
}
