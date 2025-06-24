#' Mandelbrot's adjustment on Zipf's law
#'
#' Zipf-Mandelbrot's law it's a fix of the original Zipf's law, especifically designed to be more precise in low ranks (grammatical terms).
#'
#'
#' @param text Text vector, whose elements can be phrases or documents. Note that both can be just one word
#' @return List with the adjusted parameters, that is: alpha, beta, and C. Futhermore, original data are provided
#' @examples
#' # Example with multiple texts
#' text <- c("mandelbrot is polish", "mandelbrot is french", "mandelbrot is american")
#' zipf_mandelbrot(text)
#'
#' # Example with a dataset (selected_piantadosi, available in langstats, remember to load it with data(dataset_name))
#' data(selected_piantadosi)
#' zipf_mandelbrot(selected_piantadosi)
#' @export
#' @importFrom stats nls coef
zipf_mandelbrot <- function(text) {
  words <- tolower(unlist(strsplit(text, "\\W+")))
  words <- words[words != ""]
  freq <- sort(table(words), decreasing = TRUE)
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
    warning("The model could not be adjusted. The reason may be: ", e$message)
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
