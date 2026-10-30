#' Create Synthetic Window Metadata
#'
#' Build default SCRI window metadata for each outcome, including control,
#' induction, risk, and washout windows.
#'
#' @param outcomes Character vector of outcomes to include.
#'
#' @return A `data.table` with columns `outcome`, `window_name`, `start_window`,
#'   and `length_window`.
create_window_metadata <- function(outcomes = c("myocarditis", "pericarditis")) {
  base_windows <- data.table::data.table(
    window_name = c("control", "induction", "risk", "washout"),
    start_window = c(-365, 1, 43, 74),
    length_window = c(365, 42, 30, 60)
  )

  windows_data <- data.table::rbindlist(lapply(outcomes, function(i_outcome) {
    copy(base_windows)[, outcome := i_outcome]
  }))

  setcolorder(windows_data, c("outcome", "window_name", "start_window", "length_window"))
  return(windows_data[])
}

# WindowMetadata <- create_window_metadata()

# Uncomment to regenerate package data
# usethis::use_data(WindowMetadata, overwrite = TRUE)
