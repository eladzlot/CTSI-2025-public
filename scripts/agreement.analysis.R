########################
# Agreement
########################
#' Calculate agreement metrics between surface and core values.
#'
#' This function calculates various agreement metrics between surface (sf) and core (cf) values
#' based on a dataframe structure containing specific columns related to a psychological experiment.
#' 
#' The function performs the following steps:
#' - Joins surface and core values based on 'id' and 'wave'.
#' - Filters out rows where either surface or core values are entirely missing.
#' - Calculates agreement metrics and their statistical significance through bootstrapping.
#' - Generates visualizations to illustrate the distribution and comparison of sf and cf values.
#' - Computes Simpson's Diversity Index for both sf and cf values with bootstrap confidence intervals.
#'
#' @param values A dataframe containing columns:
#'   \describe{
#'     \item{id} Unique identifier for each entry.
#'     \item{type} Indicates whether the entry is 'surface' or 'core'.
#'     \item{wave} Indicates the wave number associated with each entry.
#'     \item{is_real} Indicates the how much the identified core threat reflects the real motivation of anxiety. 1 - yes, 2 - no, 3 - maybe.
#'     \item{Affiliation_sf, Predictibility_sf, Competence_sf, Control_sf, Self-image_sf, Survival_sf, Physical comfort_sf, Morality_sf} 
#'       Columns containing values chosen for surface (sf) attributes.
#'     \item{Affiliation_cf, Predictibility_cf, Competence_cf, Control_cf, Self-image_cf, Survival_cf, Physical comfort_cf, Morality_cf} 
#'       Columns containing values chosen for core (cf) attributes.
#'     \item{Distress tolerance_sf, No Idea_sf, Distress tolerance_cf, No Idea_cf} Columns indicating distress tolerance and uncertainty.
#'   }
#'   The function expects that both 'surface' and 'core' entries are present for each unique combination of id and wave.
#'
#' @return A list containing:
#'   - \code{N}: Number of individuals (length of cf values).
#'   - \code{actual_count}: Count of actual agreements between sf and cf values.
#'   - \code{bychance.boot}: Bootstrap estimates of expected agreements by chance.
#'   - \code{expected_count}: Median of expected agreements by chance.
#'   - \code{expected_p}: Proportion of bootstrap samples where agreements by chance are greater than or equal to actual agreements.
#'   - \code{graph}: Plot illustrating the distribution and comparison of sf vs cf values.
#'   - \code{D_sf}: Bootstrap confidence intervals for Simpson's Diversity Index of sf values.
#'   - \code{D_cf}: Bootstrap confidence intervals for Simpson's Diversity Index of cf values.
#'   - \code{D_perc_sfcf}: Percentage of bootstrap samples where D_cf is greater than D_sf.
#'
#' @examples
#' # Example dataframe structure:
#' # id type wave Affiliation_sf Predictibility_sf Control_sf ... Distress tolerance_cf No Idea_cf
#' # x049 surface 1 NA NA NA ... NA NA
#' # x049 core 1 NA x NA ... x NA
#'
#' # Example usage:
#' # agreement(values)
#'
#' @export
agreement = function(values, R = 1e4) {
  
  # Smart pivot wider
  aligned_df = full_join(
    # Filter surface and core types and join them on id and wave
    values %>% filter(type == "surface"),
    values %>% filter(type == "core"),
    by = c("id", "wave"), suffix = c("_sf", "_cf")
  ) %>%
    # We require both sf and cf to talk about agreement
    filter(!if_all(Affiliation_sf:`No Idea_sf`, is.na)) %>% # Remove rows with no sf values
    filter(!if_all(Affiliation_cf:`No Idea_cf`, is.na)) %>% # Remove rows with no cf values
    select(-matches('^type|Comments')) # Drop 'type' and 'Comments' columns
  
  # Get actual values chosen by each individual for surface (sf) and core (cf)
  values_sf = aligned_df %>% 
    select(Affiliation_sf:`No Idea_sf`) %>% 
    as.matrix %>% 
    apply(1, function(i) { which(!is.na(i)) }) # Find indices of non-NA values
  
  values_cf = aligned_df %>% 
    select(Affiliation_cf:`No Idea_cf`) %>% 
    as.matrix %>% 
    apply(1, function(i) { which(!is.na(i)) }) # Find indices of non-NA values
  
  # Number of individuals
  N = length(values_cf)
  
  # Count of actual agreements
  actual_count = agree_list(values_sf, values_cf)
  
  # Bootstrap to determine how many agreements we expect by chance
  bychance.boot = sapply(1:R, function(i) {
    combined = sample(c(values_sf, values_cf), replace = FALSE)
    agree_list(combined[1:N], combined[(N + 1):(N * 2)])
  })
  
  # Calculate expected count and p-value for agreements by chance
  expected_count = median(bychance.boot)
  expected_p = mean(bychance.boot >= actual_count)
  
  # Number of times that participants identified core threats as true motivation
  # ??????
  
  # Calculate Simpson's Diversity Index and bootstrap confidence intervals
  D_sf = bootstrap_ci_D(values_sf, agree_fn, R = R)
  D_cf = bootstrap_ci_D(values_cf, agree_fn, R = R)
  
  # Calculate the percentage of D_cf samples greater than D_sf samples
  D_perc_sfcf = mean(D_cf$D_samples > D_sf$D_samples)
  
  # Return the results as a list
  list(
    N=N, 
    actual_count=actual_count, 
    bychance.boot=bychance.boot, 
    expected_count=expected_count, 
    expected_p=expected_p, 
    values_sf = values_sf,
    values_cf = values_cf,
    is_real = aligned_df$is_real_cf,
    D_sf = D_sf,
    D_cf = D_cf,
    D_perc_sfcf=D_perc_sfcf
  )
}



