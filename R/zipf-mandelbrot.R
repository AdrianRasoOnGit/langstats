#' Mandelbrot's adjustment on Zipf's law
#'
#' Zipf-Mandelbrot's law it's a fix of the original Zipf's law, especifically designed to be more precise in low ranks (grammatical terms).
#'
#'
#' @param input Text vector, whose elements can be phrases or documents, or data frame, for example, from the output of ngram(). Bear in mind that, as it has been defined, words must be on the first column! (Not anymore, input_handling() has acquired smart features!)
#' @param level As in other functions in langstats, allows the user to define the linguistic layer we aim to study, whether it is word, or letter
#' @return List with the adjusted parameters, that is: alpha, beta, and C. Furthermore, original data are provided
#' @examples
#' # Example with multiple texts
#' text <- c("mandelbrot is polish", "mandelbrot is french", "mandelbrot is american")
#' zipf_mandelbrot(text)
#'
#' # Example with a dataset (selected_piantadosi)
#' data(selected_piantadosi)
#' zipf_mandelbrot(selected_piantadosi)
#' @export
#' @importFrom stats nls coef
zipf_mandelbrot <- function(input, level = c("word", "letter")) {
  # Standardize input
  input_data <- input_handling(input, level = level)
  tokens <- input_data$elements

  if (length(tokens) == 0) {
    warning("No tokens were found in the input!")
    return(NULL)
  }

  # Create frequency and rank data
  freq <- sort(table(tokens), decreasing = TRUE)
  df <- data.frame(
    token = names(freq),
    rank = seq_along(freq),
    frequency = as.numeric(freq)
  )

  # Nonlinear model: f(r) = C / (r + beta)^alpha
  model <- tryCatch({
    nls(frequency ~ C / (rank + beta)^alpha,
        data = df,
        start = list(C = max(df$frequency), beta = 1, alpha = 1.0),
        control = list(maxiter = 1000))
  }, error = function(e) {
    warning("It hasn't been possible to adjust the model. Have you considered this? ", e$message)
    return(NULL)
  })

  if (is.null(model)) return(NULL)

  params <- coef(model)
  list(
    alpha = params["alpha"],
    beta = params["beta"],
    C = params["C"],
    data = df,
    model = model
  )
}
