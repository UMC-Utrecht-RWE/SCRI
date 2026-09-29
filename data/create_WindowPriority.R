#' Create Window Priority Table (Long Format)
#'
#' Create a long-format matrix of all combinations between dose N and dose N+1
#' windows and assign a default priority label.
#'
#' @param window_names Character vector of window names used to build all
#'   pairwise combinations.
#'
#' @return A `data.table` with columns `dose_n_window`,
#'   `dose_n_plus_1_window`, and `priority`.
create_windows_priority <- function(
  window_names = c("control", "induction", "risk", "washout")
) {
  windows_data <- CJ(
    dose_n_window = window_names,
    dose_n_plus_1_window = window_names,
    sorted = FALSE
  )

  windows_data[, priority := "B"]

  return(windows_data[])
}

#' Convert Window Priority to MxM Wide Format
#'
#' Convert the long-format priority table produced by
#' `create_windows_priority()` into a two-way wide table.
#'
#' @param windows_priority_long A long-format priority table.
#'
#' @return A `data.table` where rows are `dose_n_window` and columns are
#'   `dose_n_plus_1_window`.
create_windows_priority_mxm <- function(windows_priority_long) {
  mxm_table <- dcast(
    windows_priority_long,
    dose_n_window ~ dose_n_plus_1_window,
    value.var = "priority"
  )

  setnames(mxm_table, "dose_n_window", "dose_n_window_vs_dose_n_plus_1_window")

  return(mxm_table[])
}

load("~/Documents/GitHub/SCRI/data/WindowMetadata.rda")

# Execute the function and assign the result to WindowPriority
# WindowPriority <- create_windows_priority(window_names = unique(WindowMetadata$window_name))
# WindowPriority <- create_windows_priority_mxm(WindowPriority)

# Save as RDS and CSV
# usethis::use_data(WindowPriority, overwrite = TRUE)
