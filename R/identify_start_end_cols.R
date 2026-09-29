#' Identify Start and End Column Names
#'
#' This function identifies columns in a data.table that follow the naming convention
#' of starting with "start_" or "end_". It's used for identifying time window columns.
#'
#' @param data A data.table containing columns with names starting with "start_" and "end_"
#'
#' @return A list with two elements:
#'   \item{start_names}{Character vector of column names starting with "start_"}
#'   \item{end_names}{Character vector of column names starting with "end_"}
#'
#' @keywords internal
identify_start_end_cols <- function(data){
  # obtain window names (assumes input is data.table, has this naming convention for columns)
  start_names <- names(data)[grep("^start_", names(data))]
  end_names <- names(data)[grep("^end_", names(data))]
  return(list('start_names' = start_names, 'end_names' = end_names))
}