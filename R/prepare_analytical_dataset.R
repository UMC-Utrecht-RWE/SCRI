#' Prepare Analytical Dataset from SCRI Identified Records
#'
#' This function processes a dataset of SCRI (Self-Controlled Analysis) identified records
#' and prepares it for further analytical use. It can aggregate events by patient ID and
#' optionally merge with a stratification variable.
#'
#' @param SCRI_identified_records A data.table containing SCRI identified records with columns:
#'        id, outcome, window_name, window_length, date
#' @param strata_column_name Character string specifying the column name in study_population
#'        to use for stratification. Default is NULL (no stratification).
#' @param only_first_date Logical. If TRUE, only the first event is considered.
#'        If FALSE, all events are summed. Default is FALSE.
#'
#' @return A data.table with processed data ready for analysis
#'
#' @examples
#' \dontrun{
#' data <- data.table(
#'   id = 1:3, outcome = "SCRI", window_name = "W1",
#'   window_length = 30, date = as.Date(c("2023-01-01", NA, "2023-02-15"))
#' )
#' pop <- data.table(id = 1:3, gender = c("M", "F", "M"))
#' prepare_analytical_dataset(data, "gender", FALSE, pop)
#' }
#'
#' @importFrom data.table fifelse
#' @export
prepare_analytical_dataset <- function(SCRI_identified_records,
                                       strata_column_name = NULL,
                                       only_first_date = FALSE) {
  # Create event indicator based on date availability
  SCRI_identified_records[, event := data.table::fifelse(is.na(date), 0, 1)]

  sel_cols <- c("id", "outcome", "window_name", "window_length", "event", strata_column_name)
  by_cols <- c("id", "outcome", "window_name", "window_length", strata_column_name)
  # Select relevant columns
  SCRI_identified_records <- SCRI_identified_records[, ..sel_cols, with = F]

  # Process based on only_first_date parameter
  if (only_first_date == FALSE) {
    # Sum all events by grouping variables
    SCRI_identified_records <- SCRI_identified_records[, .(event = sum(event)),
      by = by_cols
    ]
  } else {
    # If only interested in whether there was any event
    SCRI_identified_records <- SCRI_identified_records[, .(event = as.integer(any(event > 0))),
      by = by_cols
    ]
  }

  return(SCRI_identified_records)
}
