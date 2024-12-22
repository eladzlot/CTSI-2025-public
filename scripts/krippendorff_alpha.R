library(tidyverse)
library(here)

#' Calculate Krippendorff's IRR alpha agreement score
#'
#' This function computes Krippendorff's Inter Rater Reliability (IRR) alpha to
#' assess agreement between judges in the provided data.
#' It takes four arguments:
#'
#' * `jid`: A vector containing judge IDs.
#' * `uid`: A vector containing unit IDs.
#' * `values`: A list of values, where each element is a judgment
#' * `agree`: An agreement function that takes two vectors of the same length and returns
#'           a numerical agreement score. This function can support asymmetric
#'           agreement metrics beyond simple concordance or distance-based comparisons.
#'           By default, agree is set to the simple concordance function (a=b)
#'
#' @return Kripendorfs alpha
#'
#' @references
#' Krippendorff, K. (2018). Content Analysis: An Introduction to Its Methodology. SAGE Publications.
#'
#' @examples
#' # Assuming you have judge IDs, unit IDs, values, and an agreement function defined
#' krip_alpha <- krippendorff(jid, uid, values, agree)

krippendorff = function(jid, uid, values, agree = function(a, b){a == b}){
  # ensure all data have the same length
  if (length(jid) != length(uid) | length(uid) != length(values)) stop('Krippendorff: jid, uid, unit must have the same length')
  
  # units with only one response don't provide reliability information - remove them
  # also, any row with NA
  remove_map = which((duplicated(uid) | duplicated(uid, fromLast = TRUE)) & !is.na(values)) 
  jid = jid[remove_map]
  uid = uid[remove_map]
  values = values[remove_map]
  
  n = length(values)
  
  # create map of question pairs uid->idx
  unit_idx = list()
  for (i in 1:length(uid)) unit_idx[[as.character(uid[i])]] = c(unit_idx[[as.character(uid[i])]], i)
  
  # Count disagreements
  agreement = 0
  
  for (idx in unit_idx){
    nunit = length(idx)
    for (i in 1:(nunit-1)) {
      for (j in (i+1):nunit){
        # agreement can be asymetrical, therefore we seperately add each direction
        agreement = agreement + agree(values[[idx[i]]], values[[idx[j]]])/(nunit-1)
        agreement = agreement + agree(values[[idx[j]]], values[[idx[i]]])/(nunit-1)
        ## print(paste('unit:',idx[i], idx[j],'agreement:', agreement, sep = ', '))
      } # judge j
    } # judge i
  } # units (idx)
  
  
  # count expected number of disagreements for each response (with memoization)
  cache = list()
  expected = function(value){
    name = paste(value, collapse=',') # consider a better hashing function?
    if (!(name %in% names(cache))) cache[[name]] <<- sum(unlist(sapply(values, agree, a=value)))
    return(cache[[name]])
  }
  
  # Calculate D_e
  expected_disagreement = (n^2 - sum(unlist(sapply(values, expected))))/(n-1)
  
  # calculate D_o
  observed_disagreement = n - agreement
  print(paste0('obs disagreement: ', observed_disagreement))
  print(paste0('exp disagreement: ', expected_disagreement))
  print(paste0('n: ', n))
  return(1 - observed_disagreement/expected_disagreement)
}

#########################################################
## Tests: make sure our K is equivalent to the standard
#########################################################
#library(irr)
#jid = rep(1:4, each=12)
#uid = rep(1:12, 4)
#values = ifelse(runif(48)>.15,sample(1:6, 48, replace=TRUE), NA)
#kripp.alpha(values %>% matrix(ncol=4) %>% t)$value -  krippendorff(jid, uid, values)
