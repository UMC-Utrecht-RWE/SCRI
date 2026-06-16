#' Synthetic Study Population
#'
#' A synthetic study population; one row per individual with relevant date variables
#'
#' @format ## `StudyPopulation`
#' A data frame with 100 rows and 6 variables:
#' \describe{
#'   \item{id}{identifier for unique individuals}
#'   \item{reference_date_name}{Date variables relating to the anchor date for the analysis. This can be multiple different columns.}
#'   \item{reference_date}
#'   \item{start_followup_criteria}{Date variables relating to the start of the follow up )}
#'   \item{end_followup_criteria}{Date variables relating to the end of the follow up (end follow up dates, death as censoring event dates)}
#' }
"StudyPopulation"



