#' Create Synthetic Study Population
#'
#' Generate a synthetic study population with vaccine dates and follow-up
#' related dates used by SCRI examples and tests.
#'
#' @param n Integer number of individuals to generate.
#' @param seed Integer random seed used for reproducible generation.
#'
#' @return A `data.table` with one row per individual and date columns required
#'   for SCRI workflows.
create_study_population <- function(n = 100, seed = 123) {
  set.seed(seed)

  ids <- sprintf("%03d", seq_len(n))
  dose_1 <- as.Date("2021-01-01") + sample(0:730, n, replace = TRUE)

  has_second_dose <- sample(c(TRUE, FALSE), n, replace = TRUE, prob = c(0.8, 0.2))
  gap_days <- sample(21:180, n, replace = TRUE)
  dose_2 <- as.Date(NA)
  dose_2 <- rep(dose_2, n)
  dose_2[has_second_dose] <- dose_1[has_second_dose] + gap_days[has_second_dose]

  op_start_date <- dose_1 - sample(180:720, n, replace = TRUE)
  general_end_fup <- dose_1 + sample(120:730, n, replace = TRUE)

  death_indicator <- sample(c(TRUE, FALSE), n, replace = TRUE, prob = c(0.1, 0.9))
  death_date <- as.Date(NA)
  death_date <- rep(death_date, n)
  death_date[death_indicator] <- dose_1[death_indicator] + sample(30:540, sum(death_indicator), replace = TRUE)

  dt <- data.table::data.table(
    id = ids,
    covid_vaccine_1 = dose_1,
    covid_vaccine_2 = dose_2,
    op_start_date = op_start_date,
    death_date = death_date,
    general_end_fup = general_end_fup
  )

  return(dt[])
}

# StudyPopulation <- create_study_population()

# Uncomment to regenerate package data
# usethis::use_data(StudyPopulation, overwrite = TRUE)
