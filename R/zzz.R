#' Package initialization hook
#'
#' Suppress R CMD check notes for data.table's non-standard evaluation
#'
#' @name zzz
#' @keywords internal
#' 
#' @importFrom data.table as.data.table
#' @importFrom stats as.formula end na.omit start

utils::globalVariables(c(
  # data.table's non-standard evaluation
  ".",      # data.table's .() syntax
  ".SD",    # Subset of Data
  ".N",     # Number of rows
  ".I",     # Row indices
  ".GRP",   # Group counter
  ".BY",     # List of by values
  ":=",
  "..sel_cols", "..start_names", "end", "event", "int_censdate", "key", 
  "length_window", "log_length", "outcome", "overlapping_windows", 
  "previous_end", "previous_window", "reference_date", "scri_identified_records", 
  "start", "start_window", "strata", "variable", "window_length", "window_name"
 
  # Add unquoted column names here if needed:
  # "column_name",
  # "another_column"
))