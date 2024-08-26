#' wide_to_long_trimmed_windows
#'
#' This function takes windows_trimmed in a wide format and transforms it in a long format.
#'
#' @param wide_file_windows_trimmed A data table in wide format.
#' @param start_prefix A string that defines the prefix for the start of a window. Default is "start".
#' @param end_prefix A string that defines the prefix for the end of a window. Default is "end".
#'
#' @return A data table in long format.
#'
#' @export
#' @importFrom data.table .SD
wide_to_long_trimmed_windows <- function(wide_file_windows_trimmed, start_prefix = "start", end_prefix = "end") {
  # Identification of the date columns defining the start and end of a window
  windows_start <- names(wide_file_windows_trimmed)[stringr::str_detect(names(wide_file_windows_trimmed), paste0("^", start_prefix))]
  windows_end <- names(wide_file_windows_trimmed)[stringr::str_detect(names(wide_file_windows_trimmed), paste0("^", end_prefix))]

  # Identification of the variables that are not dates
  id_vars <- names(wide_file_windows_trimmed)[!names(wide_file_windows_trimmed) %in% c(windows_start, windows_end)]

  # Transformation from wide to long format
  intermediate_long_file_windows_trimmed <- data.table::melt(wide_file_windows_trimmed, id.vars = id_vars, measures.vars = c(windows_start, windows_end))

  # Splitting the variable column to identify whether the row has a start or end value of a window
  intermediate_long_file_windows_trimmed[, c("type", "WindowName") := data.table::tstrsplit(sub("_", " ", variable), " ")][, variable := NULL]

  # Casting to long format but only the date values
  long_file_windows_trimmed <- data.table::dcast(intermediate_long_file_windows_trimmed, ... ~ factor(type, levels = c(start_prefix, end_prefix)), value.var = "value")

  return(long_file_windows_trimmed)
}
