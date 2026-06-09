#' Package initialization hook
#'
#' Suppress R CMD check notes for data.table's non-standard evaluation
#'
#' @name zzz
#' @keywords internal
utils::globalVariables(c(
  # data.table's non-standard evaluation
  ".",      # data.table's .() syntax
  ".SD",    # Subset of Data
  ".N",     # Number of rows
  ".I",     # Row indices
  ".GRP",   # Group counter
  ".BY",     # List of by values
  ":="
 
  # Add unquoted column names here if needed:
  # "column_name",
  # "another_column"
))
