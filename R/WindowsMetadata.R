#' WindowMetadata
#'
#' A metadata file, describing different window types (control, exposed, lookback, induction, washout) for SCRI analysis and how they are anchored
#'
#' @format ## `WindowMetadata`
#' A data frame with 8 rows and 4 variables:
#' \describe{
#'   \item{outcome}{Outcome identifier (e.g., myocarditis, pericarditis).}
#'   \item{window_name}{window identifier (chr)}
#'   \item{start_window}{How many days before reference_date does the window start? start_date = reference_date + start_window}
#'   \item{length_window}{How many days after start_date does the window end? end_date = reference_date + start_window + length_window -1}
#' }
"WindowMetadata"
