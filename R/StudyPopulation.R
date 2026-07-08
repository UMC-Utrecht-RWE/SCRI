#' Synthetic Study Population
#'
#' A synthetic study population; one row per individual with relevant date variables
#'
#' @format ## `StudyPopulation`
#' A data frame with 100 rows and 6 variables:
#' \describe{
#'   \item{id}{identifier for unique individuals}
#'   \item{covid_vaccine_1}{Date of first COVID-19 vaccine dose (primary anchor date).}
#'   \item{covid_vaccine_2}{Date of second COVID-19 vaccine dose (optional anchor date).}
#'   \item{start_followup_criteria}{Date variables relating to the start of the follow up )}
#'   \item{end_followup_criteria}{Date variables relating to the end of the follow up (end follow up dates, death as censoring event dates)}
#' }
"StudyPopulation"
