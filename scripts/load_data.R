library(here)
library(tidyverse)
library(psych)

source(here('scripts', 'helpers.files.R'))

############################
# OCD
############################
read_dfs_from_csv(c('ocd.values', 'ocd.ocir', 'ocd.demog'))

ocd.N = ocd.values %>% pull(id) %>% unique %>% length
ocd.femaleN = sum(ocd.demog$gender == 2)
ocd.age.mean = ocd.demog$age %>% mean
ocd.age.sd = ocd.demog$age %>% sd
ocd.diamondN = sum(ocd.demog$diamond_has_ocd == 1, na.rm=TRUE)
ocd.ocir.mean = ocd.ocir %>% pull(sum_ocir) %>% mean
ocd.ocir.median = ocd.ocir %>% pull(sum_ocir) %>% median()
ocd.ocir.sd = ocd.ocir %>% pull(sum_ocir) %>% sd
ocd.ocir.omega = omega(ocd.ocir %>% select(starts_with('ocir')))$omega.tot

############################
# STICSA
############################

read_dfs_from_csv(c('sticsa.values', 'sticsa.sticsa', 'sticsa.demog'))

sticsa.N = sticsa.values %>% pull(id) %>% unique %>% length
sticsa.femaleN = sum(sticsa.demog$gender == 2)
sticsa.age.mean = sticsa.demog$age %>% mean
sticsa.age.sd = sticsa.demog$age %>% sd

sticsa.dropoutN = sticsa.demog$time_diff %>% is.na %>% sum
sticsa.days.median = median(sticsa.demog$time_diff, na.rm = TRUE) %>% round
sticsa.days.max = max(sticsa.demog$time_diff, na.rm = TRUE) %>% round
sticsa.days.min = min(sticsa.demog$time_diff, na.rm = TRUE) %>% round

sticsa.sticsa.mean = sticsa.sticsa %>% pull(sum_sticsa) %>% mean
sticsa.sticsa.sd = sticsa.sticsa %>% pull(sum_sticsa) %>% sd
sticsa.sticsa.omega = omega(sticsa.sticsa %>% select(starts_with('sticsa')))$omega.tot

############################
# Online
############################
read_dfs_from_csv(c('online.values', 'online.sticsa'))

online.N = online.sticsa %>% pull(id) %>% unique %>% length
online.sticsa.mean = online.sticsa %>% pull(sum_sticsa) %>% mean
online.sticsa.sd = online.sticsa %>% pull(sum_sticsa) %>% sd
online.sticsa.omega = omega(online.sticsa %>% select(starts_with('sticsa')))$omega.tot

############################
# WET
############################
read_dfs_from_csv(c('wet.values', 'wet.oasis', 'wet.demog'))

wet.N = wet.oasis %>% pull(id) %>% unique %>% length
wet.femaleN = sum(wet.demog$Sex == 'Female')
wet.age.mean = suppressWarnings(wet.demog$Age %>% as.numeric %>% mean(na.rm = TRUE))
wet.age.sd = suppressWarnings(wet.demog$Age %>% as.numeric %>% sd(na.rm = TRUE))

# oasis
wet.oasis.mean = wet.oasis %>% pull(sum_oasis) %>% mean
wet.oasis.sd = wet.oasis %>% pull(sum_oasis) %>% sd
wet.oasis.omega = omega(wet.oasis %>% select(starts_with('oasis')), nfactors = 1)$omega.tot
