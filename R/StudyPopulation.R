#' Synthetic Study Population
#'
#' A synthetic study population; one row per individual with relevant date variables
#'
#' @format ## `StudyPopulation`
#' A data frame with 100 rows and 6 variables:
#' \describe{
#'   \item{person_id}{identifier for unique iindividuals}
#'   \item{op_start_date, death_date, general_end_fup}{Date variables relating to follow up (start and end follow up dates, death as censoring event)}
#'   \item{FIRST_TARGET, SECOND_TARGET}{Date variables relating to dates of exposures, anchor/reference dates}
#' }
"StudyPopulation"
