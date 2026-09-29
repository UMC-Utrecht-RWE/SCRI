#' Create Synthetic Records Table
#'
#' Generate a synthetic records table anchored on `covid_vaccine_1` from a study
#' population. Each person receives between 1 and 3 records with random dates,
#' values, and outcomes.
#'
#' @param study_population A data frame or data.table containing at least `id`
#'   and `covid_vaccine_1` columns.
#' @param seed Integer random seed used for reproducible generation.
#'
#' @return A `data.table` with columns `id`, `date`, `value`, and `outcome`.
create_records_table <- function(study_population, seed = 123) {
  set.seed(seed)

  if (!"id" %in% names(study_population)) stop("study_population must include 'id'.")
  if (!"covid_vaccine_1" %in% names(study_population)) stop("study_population must include 'covid_vaccine_1'.")

  outcomes <- c("myocarditis", "pericarditis")
  rows <- lapply(seq_len(nrow(study_population)), function(i) {
    person_id <- study_population$id[i]
    anchor <- study_population$covid_vaccine_1[i]
    n_records <- sample(1:3, 1)

    data.table::data.table(
      id = rep(person_id, n_records),
      date = anchor + sample(-30:90, n_records, replace = TRUE),
      value = sample(1:200, n_records, replace = TRUE),
      outcome = sample(outcomes, n_records, replace = TRUE)
    )
  })

  dt <- data.table::rbindlist(rows)
  return(dt[])
}

# if (exists("StudyPopulation")) {
#   RecordsTable <- create_records_table(StudyPopulation)
# } else {
#   load("data/StudyPopulation.rda")
#   RecordsTable <- create_records_table(StudyPopulation)
# }

# Uncomment to regenerate package data
# usethis::use_data(RecordsTable, overwrite = TRUE)
