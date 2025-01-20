library(here)
library(tidyverse)
source(here('scripts', 'helpers.files.R'))

"%notin%" <- Negate("%in%")

get_qualtrics = function(...){
  read_csv(
    here('raw',...),skip = 3,
    col_names = read_csv(here('raw',...),col_names = FALSE, n_max = 1) %>% as.character() %>% tolower()
  )
}

##########################################################
# OCD tidy
#########################################################

ID_filter = '^x|z[[:digit:]]+$'

# Just cleanup interview data
ocd.interview =  get_qualtrics('ocd','interview.csv') %>%
  filter(str_detect(uid, ID_filter )) %>%
  filter(
    responseid %notin% c(
      'R_2rGiOcWdUt5iCn6' # z004 duplicate entry
    )
  ) %>%
  # fix wrong uid
  mutate(
    uid = if_else(responseid == 'R_pFALoTl259eiV8J', 'x022', uid),
    uid = if_else(responseid == 'R_1IhZ2zaR6RVWCiL', 'x050', uid)
  ) %>% 
  filter(!is.na(int_text_sf_1))

# Build fears data
# (keep this separate from the tidy because we also want diamond data)
ocd.fears = ocd.interview %>%
  # drop useless columns
  select(
    id = uid,
   int_text_sf_1, int_text_sf_2,
    int_text_cf_1, int_text_cf_2,
  ) %>%
  # organize in long form
  pivot_longer(
    cols = starts_with('int'),
    names_to = c('type','wave'),
    names_pattern = 'int_text_(..)_(.)',
    values_to = 'fear',
    values_drop_na = TRUE
  ) %>%
  mutate(experiment = 'ocd')

# Get ocd questionnaire data
# This includes age, gender, and ocir
ocd.quest =  get_qualtrics('ocd','questionnaire.csv') %>%
  filter(str_detect(uid, ID_filter )) %>%
  filter(
    responseid %notin% c(
      'R_1ooRQtDzepVPPNR', # z001 duplicate entry
      'R_1QllhiG47mPwWsK', # z018 duplicate
      'R_6nHOr4ob8r1Fv8t',  # z031 duplicate
      'R_2B5IouaCncNi3as'  # z032 duplicate
    )
  ) %>%
  # look only at people that completed the interview
  filter(uid %in% ocd.fears$id) %>% 
  select(id = uid, gender, birth, marital_status = q3, education = q4, education_yrs = q5, is_work = q6, income = q8, religion = q12, startdate, starts_with('OCIR')) %>%
  mutate(now = format(as.POSIXct(startdate, format="%Y-%m-%d %H:%M:%S"), "%Y") %>% as.numeric) %>% 
  mutate(birth = as.numeric(birth)) %>%
  mutate(age = now-birth)

# analyzing the ocir
ocd.ocir = ocd.quest %>%
  select(starts_with('ocir')) %>%
  mutate_at(vars(ocir_1:ocir_18),list(~.x-1)) %>%
  mutate(sum_ocir = select(., ocir_1:ocir_18) %>% rowSums)

ocd.demog = ocd.quest %>% select(id, age, gender, marital_status, education, education_yrs, is_work, income, religion) %>% 
  left_join(ocd.interview %>% select(id = uid, diamond_has_ocd), by = 'id')

# make sure that we have data for the same set of individuals
stopifnot(identical(sort(ocd.fears$id) %>% unique, sort(ocd.quest$id)))
stopifnot(identical(sort(ocd.fears$id) %>% unique, sort(ocd.interview$uid)))

# creates merges concencus values with infomation on the relevant fear
# needed to remove all sorts of white spaces inserted by the movement back and forth from excel when judging (probably)
ocd.values = full_join(
  ocd.fears %>%
    mutate(fear = fear %>% str_replace_all('\\n|\\s+$','')%>% str_replace_all('  ',' ')),
  read_csv(here('raw','judges', 'CTSI.ocd.concensus.csv')) %>%
    mutate(Fear = Fear %>% str_replace_all('\\n|\\s+$','')%>% str_replace_all('  ',' ')),
  by=c('fear'='Fear')
) %>% select(-fear)

# create fear list for scoring
ocd.fears %>% mutate(rid = paste(id,type,wave, sep = '-')) %>% select(rid, fear) %>% write_csv(here('raw','ocd.judges.raw.csv'))

write_dfs_to_csv(c('ocd.values', 'ocd.ocir', 'ocd.demog'))

##########################################################
# Sticsa tidy
##########################################################
sticsa.interview =  get_qualtrics('sticsa','interview.csv') %>%
  filter(
    uid != 'fa01',
    responseid != 'R_3oBh9RU2slKy8T9', # duplicate st053 response
    responseid != 'R_2R4T7qUoBHz9F2l', # duplicate st061 response
    responseid != 'R_2PcyNYkwtM29SWm', responseid != 'R_2AEw9iXORhBLJaY', # empty st010 responses
    responseid != 'R_sL82GVneHbwXozf', responseid != 'R_9HzZYJxQWOknv4R' # empty st073 responses
  ) 

sticsa.fears = sticsa.interview %>%
  select(id = uid, wave = stage, surface_fear, core_fear, is_real = is_motivation) %>%
  pivot_longer(
    cols = c('surface_fear', 'core_fear'),
    names_to = 'type',
    values_to = 'fear',
    values_drop_na = TRUE
  ) %>% 
  mutate(type = if_else(type=='surface_fear', 'surface', 'core')) %>%
  mutate(experiment = 'sticsa', rid = row_number())


# Merge judges concencus with fear data
sticsa.values = full_join(
  sticsa.fears,
  readxl::read_xlsx(here('raw','judges', 'CTSI.sticsa.concensus.xlsx')) %>% mutate(rid = as.integer(rid)),
  by=c('rid', 'fear')
) %>% select(-fear)

sticsa.days_diff = sticsa.interview %>% 
  select(id = uid, wave = stage, time = startdate) %>% 
  pivot_wider(names_from = wave, values_from = time) %>%
  mutate(time_diff = difftime(`2`, `1`, units = "days")) %>%
  select(id, time_diff)


sticsa.quest =  get_qualtrics('sticsa','questionnaire.csv') %>%
  filter(
    responseid != 'R_beJPptElnFWxAlj', # empty st039 response
    responseid != 'R_3EYV3hfPKJj93zY', # empty st073 response
    responseid != 'R_3sdepahTsNYRNhn', # empty st076 response
    responseid != 'R_3G3TSkwaIe84333', # empty st089 response
  ) %>%
  select(id = uid, gender, birth, marital_status = q3, education = q4, education_yrs = q5, income = q8, religion = q12, startdate, starts_with('sticsa'), startdate) %>%
  mutate(now = format(as.POSIXct(startdate, format="%Y-%m-%d %H:%M:%S"), "%Y") %>% as.numeric) %>% 
  mutate(birth = as.numeric(birth)) %>%
  mutate(birth = if_else(id == 'st089', birth + 1900, birth)) %>% # one user inputed a two digit birth year
  mutate(age = now-birth) %>%
  filter(id %in% sticsa.fears$id)

sticsa.demog = sticsa.quest %>% select(id, age, gender, marital_status, education, education_yrs, income, religion) %>% 
  left_join(sticsa.days_diff)

# make sure that we have data for the same set of individuals
stopifnot(identical(sort(sticsa.fears$id) %>% unique, sort(sticsa.quest$id)))

# analyzing the ticsa
sticsa.sticsa = sticsa.quest %>%
  select(starts_with('sticsa')) %>%
  mutate_at(vars(sticsa_1:sticsa_21),list(~.x-1)) %>%
  mutate(sum_sticsa = select(., sticsa_1:sticsa_21) %>% rowSums)


# create fear list for scoring
set.seed(1337)
sticsa.fears %>% select(rid, fear) %>% slice_sample(prop = 1) %>% write_csv(here('raw','sticsa.judges.raw.csv'))

write_dfs_to_csv(c('sticsa.values', 'sticsa.sticsa', 'sticsa.demog'))

##########################################################
# Online tidy
##########################################################
online.fears =  get_qualtrics('online','interview.csv') %>%
  unite(col = 'downward', `cf_downward#2_1_1`:`cf_downward#2_5_1`, na.rm = TRUE, sep = ' --> ') %>% 
  unite(col = 'core',downward, cf_text, cf_meaning, na.rm = TRUE, sep = ' --- ') %>%
  select(id = responseid, core, surface = sf_text, is_real = cf_is_real) %>%
  pivot_longer(
    cols = c('core','surface'),
    names_to = 'type',
    values_to = 'fear',
    values_drop_na = TRUE
  ) %>%
  filter(fear != '') %>%
  mutate(wave = 1, .after = 'id') %>%
  mutate(experiment = 'online', rid = row_number())


# Merge judges concencus with fear data
online.values = full_join(
  online.fears,
  readxl::read_xlsx(here('raw','judges', 'CTSI.online.concensus.xlsx')) %>% mutate(rid = as.integer(rid)) %>% select(-fear),
  by=c('rid')
) %>% select(-fear)

# analyzing the ticsa
online.sticsa =  get_qualtrics('online','interview.csv') %>%
  filter(responseid %in% online.fears$id) %>%
  select(id = responseid, starts_with('sticsa')) %>%
  mutate_at(vars(sticsa_1:sticsa_21),list(~.x-1)) %>%
  mutate(sum_sticsa = select(., sticsa_1:sticsa_21) %>% rowSums)

# create fear list for scoring
set.seed(7331)
online.fears %>% select(rid, fear) %>% slice_sample(prop = 1) %>% write_csv(here('raw','online.judges.raw.csv'))

write_dfs_to_csv(c('online.values', 'online.sticsa'))
##########################################################
# WET tidy
##########################################################

# function to filter valid prolific ids
get_valid_pid = function(df){
  clean = df %>% 
    filter(prolific_pid != '620a6aa34b2bbf5f1b3d1f5c') %>%  # remove testing pid
    filter(grepl("^[A-Fa-f0-9]{24}$", prolific_pid))        # remove non prolific pid
  
  ids = clean$prolific_pid
  if (length(ids) != length(unique(ids))) {
    duplicate_values = ids[duplicated(ids)]
    stop("Duplicate prolific_pid found: ", paste(duplicate_values, collapse = ", "))
  } else {
    return(clean)
  }
}

d = bind_rows(
  raw.treatment.1 = get_qualtrics('wet', 'wet.treatment.1.csv') %>% get_valid_pid,
  raw.control.1 = get_qualtrics('wet', 'wet.control.1.csv') %>%
    # one participant restarted but gave no responses, we removed the empty response
    filter(responseid != 'R_OJSmJ4pvO6bGD9n') %>% get_valid_pid 
)

wet.fears =  d %>%
  unite(col = 'downward', `cf_downward#2_1_1`:`cf_downward#2_5_1`, na.rm = TRUE, sep = ' --> ') %>% 
  unite(col = 'core',downward, cf_text, cf_meaning, na.rm = TRUE, sep = ' --- ') %>%
  select(id = prolific_pid, core, surface = sf_text, is_real = cf_is_real) %>%
  pivot_longer(
    cols = c('core','surface'),
    names_to = 'type',
    values_to = 'fear',
    values_drop_na = TRUE
  ) %>%
  filter(fear != '') %>%
  mutate(wave = 1, .after = 'id') %>%
  mutate(experiment = 'wet', rid = row_number())

# Merge judges concencus with fear data
wet.values = full_join(
  wet.fears,
  readxl::read_xlsx(here('raw','judges', 'CTSI.wet.concensus.xlsx')) %>% filter(rid != 'rid') %>%  mutate(rid = as.integer(rid)) %>% select(-fear),
  by=c('rid')
) %>% select(-fear)

# analyzing the ticsa
wet.oasis =  d %>%
  select(id = prolific_pid, starts_with('oasis')) %>%
  filter(id %in% wet.fears$id) %>%
  mutate(sum_oasis = select(., oasis_1:oasis_5) %>% rowSums)

wet.demog = read_csv(here('raw','wet','demog.csv')) %>%
  filter(`Participant id` %in% wet.fears$id) %>%
  select(Sex, Age, `Ethnicity simplified`, `Student status`, `Employment status`)


# create fear list for scoring
set.seed(8452)
wet.fears %>% select(rid, fear) %>% slice_sample(prop = 1) %>% write_csv(here('raw','wet.judges.raw.csv'))

write_dfs_to_csv(c('wet.values', 'wet.oasis', 'wet.demog'))

##########################################################
# Clean judges
#########################################################

readxl::read_xlsx(here('raw/judges','CTSI.coding.sticsa.baraa.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.sticsa.baraa.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.sticsa.tomer.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.sticsa.tomer.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.sticsa.yuval.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.sticsa.yuval.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.online.baraa.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.online.baraa.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.online.tomer.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.online.tomer.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.online.yuval.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.online.yuval.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.wet.baraa.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.wet.baraa.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.wet.tomer.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.wet.tomer.csv'))
readxl::read_xlsx(here('raw/judges','CTSI.coding.wet.yuval.xlsx')) %>% select(-fear,-Comments) %>% write_csv(here('data', 'CTSI.coding.wet.yuval.csv'))
