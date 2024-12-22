#' Calculate Simpson's Diversity Index (D)
#'
#' This function computes the Simpson's Diversity Index for a dataset based on a custom
#' agreement function. The function applies the agreement function to all pairs of data points
#' to calculate the diversity index, reflecting how different the data points are from each other.
#' The index ranges from 0 (no diversity) to 1 (maximum diversity).
#'
#' @param data A list of data points, where each data point can be of any type that the
#'   delta function can handle.
#' @param delta A function that takes two data points as input and returns 1 if they agree
#'   or 0 otherwise. This function defines what it means for two data points to be considered
#'   the same.
#'
#' @return The Simpson's Diversity Index for the data as a single numeric value.
#'
#' @examples
#' data <- c("affiliation", "affiliation", "survival", "both", "survival")
#' delta <- function(a, b) { if (a == b) 1 else 0 }
#' simpson_D(data, delta)
#'
#' @export
simpson_D <- function(data, delta = function(a,b){a==b}) {
  # Determine the number of observations
  N <- length(data)
  
  # Initialize the matrix for storing pairwise agreement results
  delta_matrix <- matrix(0, nrow = N, ncol = N)
  
  # Calculate the agreements for the upper triangular matrix
  for (i in 1:(N - 1)) {
    for (j in (i + 1):N) {
      if (i == j) next
      delta_val <- delta(data[[i]], data[[j]])
      delta_matrix[i, j] <- delta_val
      delta_matrix[j, i] <- delta_val  # Use symmetry to reduce computation
    }
  }
  
  # Handle diagonal values; comparing elements with themselves
  for (i in 1:N) {
    delta_matrix[i, i] <- delta(data[[i]], data[[i]])
  }
  
  # Calculate the Simpson's D index
  D <- sum(delta_matrix) / (N*(N-1))
  
  # Return the diversity index
  return(D)
}

#' Bootstrap Confidence Interval for Simpson's Diversity Index with APA Format Output
#'
#' This function calculates the bootstrap confidence interval for Simpson's Diversity Index
#' using a specified number of bootstrap samples and a user-defined agreement function.
#' The result is returned as an object of class `simpson_D`, which includes bootstrap samples,
#' the mean D, the confidence interval, and a formatted APA string that reflects the actual
#' confidence level used.
#'
#' @param data A list of data points.
#' @param delta A function that takes two data points as input and returns 1 if they agree or 0 otherwise.
#' @param R The number of bootstrap resamples to perform.
#' @param conf_level The confidence level for the interval (default is 0.95).
#'
#' @return An object of class `simpson_D` containing bootstrap samples, the mean D, the CI, and an APA string.
#'   This object prints in APA format when displayed.
#'
#' @examples
#' data <- c("affiliation", "affiliation", "survival", "both", "survival")
#' delta <- function(a, b) { if (a == b) 1 else 0 }
#' result <- bootstrap_ci_D(data, delta, R = 1000)
#' print(result)
#'
#' @export
bootstrap_ci_D <- function(data, delta, R = 1e4, conf_level = 0.95) {
  D_samples <- numeric(R)
  
  # Perform bootstrapping
  for (i in 1:R) {
    resampled_data <- sample(data, length(data), replace = TRUE)
    D_samples[i] <- simpson_D(resampled_data, delta)
  }
  
  # Calculate the confidence interval
  alpha <- 1 - conf_level
  CI <- quantile(D_samples, probs = c(alpha/2, 1 - alpha/2))
  median_D <- median(D_samples)
  
  # Prepare APA format string, adjusting for the given confidence level
  conf_percent <- conf_level * 100
  apa_string <- sprintf("Simpsons $D$ = %.2f, _%.1f%% CI_ [%.2f, %.2f]", median_D, conf_percent, CI[1], CI[2])
  apa_string_short <- sprintf("%.2f [%.2f, %.2f]", median_D, CI[1], CI[2])
  
  # Create output object with class 'simpson_D'
  result <- list(
    median_D = median_D,
    CI = CI,
    D_samples = D_samples,
    apa_string = apa_string,
    apa_string_short = apa_string_short
  )
  class(result) <- "simpson_D"
  
  return(result)
}

# Custom print method for objects of class 'simpson_D'
print.simpson_D <- function(x) {
  cat(x$apa_string, "\n")
  invisible(x)
}

