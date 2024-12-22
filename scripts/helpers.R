library(tidyverse)
library(here)

MOTIVATIONS = c('Affiliation', 'Predictability','Competence',
                'Control', 'Self-Image','Survival','P. Comfort',
                'Morality','D. Tolerance','Ambiguous')

agree_fn = function(a,b){length(intersect(a,b))>0}
agree_list = function(a, b){
  sapply(1:length(a), function(i){agree_fn(a[[i]], b[[i]])}) %>% sum
}

#' Convert fraction to APA-formatted Markdown percentage
#'
#' This function takes a numerical input representing a fraction and converts it
#' to a percentage format according to APA style guidelines, with the output
#' formatted in Markdown for bold emphasis suitable for inclusion in APA journals.
#'
#' @param fraction A numeric value between 0 and 1 representing a fraction.
#'
#' @return A character string of the fraction formatted as a percentage in Markdown.
#'
#' @examples
#' apa_percentage(0.256)  # returns "25.6%"
#' apa_percentage(0.03)   # returns "3.0%"
#'
#' @export

apa_percentage <- function(fraction) {
  if (!is.numeric(fraction) || fraction < 0 || fraction > 1) {
    stop("Input must be a numeric value between 0 and 1.")
  }
  
  # Convert fraction to percentage and format directly into Markdown syntax
  # Format the percentage to one decimal place according to APA style and add bold markdown
  return(sprintf("%.1f%%", fraction * 100))
}

format_count_percentage <- function(count, N) { sprintf("%.f (%.2f%%)", count, (count / N) * 100) }
format_mean_sd <- function(m, s) {sprintf("%.1f (%.1f)", m,  s)}

