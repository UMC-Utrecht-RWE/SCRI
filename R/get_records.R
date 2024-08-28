#' Select Dates Window
#'
#' This function identifies all records within the records_table that fall within a window specified in the scri_trimmed table in the start and end columns.
#'
#' @param scri_trimmed The input data object recording start/end dates of each window per person, after trimming and cleaning. May be a wide or long format, output of clean_windows
#' @param variable_name The name of the variable.
#' @param window_name The name of the window.
#' @param records_table The record table data object of interest; long format dataset with events per row, minimum expected columns are: person_id, date, value.
#' @param only_first_date A boolean indicating whether to only use the first date. Default is FALSE.
#' @param wide_format_input A boolean indicating whether the records table is in wide format or not. TRUE applies a melting procedure.
#' @param start_prefix A string that defines the prefix for the start of a window. Default is "start".
#' @param end_prefix string that defines the prefix for the end of a window. Default is "end".
#' @return A data table with the result of the query.
#'
#' @export
#'
get_records <- function(scri_trimmed,
                        variable_name,
                        window_name,
                        records_table, # record table of interest, minimum expected columns are: person_id, date, value
                        only_first_date = FALSE,
                        wide_format_input = TRUE,
                        start_prefix = "start",
                        end_prefix = "end") {

  if (wide_format_input) {
      scri_trimmed_c <- wide_to_long_trimmed_windows(
        wide_file_windows_trimmed = scri_trimmed,
        start_prefix_name = start_prefix,
        end_prefix_name = end_prefix
      )
  }else{
    scri_trimmed_c <- scri_trimmed
  }

  if (only_first_date == TRUE) {
    only_first_date_part1 <- c(paste0(",ROW_NUMBER () OVER (
                                            PARTITION BY person_id
                                            ORDER BY date ASC
                                            )  NB"))
  } else {
    only_first_date_part1 <- ""
  }

  if (only_first_date == TRUE) {
    only_first_date_part2 <- "WHERE NB = 1"
  } else {
    only_first_date_part2 <- ""
  }

  # Finding the event cases after the reference date
  query <- paste0(
    "SELECT person_id, '", variable_name, "' AS variable,  '", window_name, "' AS WindowName, WindowLength, date AS Date , START_DATE, END_DATE
    FROM (",
    "SELECT *",
    only_first_date_part1,
    " FROM (",
    "SELECT DISTINCT t1.person_id, t2.date, (t1.", end_prefix, " - t1.", start_prefix, ")
                    AS  WindowLength, t1.", start_prefix, " AS START_DATE, t1.", end_prefix, " AS END_DATE",
    " FROM scri_trimmed_c t1",
    " INNER JOIN records_table t2",
    " ON (t1.person_id = t2.person_id
          AND (t2.date BETWEEN t1.", start_prefix, " AND t1.", end_prefix, ") AND t1.WindowName == '", window_name, "')",
    ")",
    ")",
    only_first_date_part2
  )


  result_query_dt <- data.table::as.data.table(sqldf::sqldf(query))

  result_query_dt[, Date := as.Date(Date, origin = "1970-01-01")]
  result_query_dt[, START_DATE := as.Date(START_DATE, origin = "1970-01-01")]
  result_query_dt[, END_DATE := as.Date(END_DATE, origin = "1970-01-01")]

  return(result_query_dt)
}


#' wide_to_long_trimmed_windows
#'
#' This function takes windows_trimmed in a wide format and transforms it in a long format.
#'
#' @param wide_file_windows_trimmed A data table in wide format.
#' @param start_prefix_name A string that defines the prefix for the start of a window. Default is "start".
#' @param end_prefix_name A string that defines the prefix for the end of a window. Default is "end".
#'
#' @return A data table in long format.
#'
#' @importFrom data.table .SD
#' @keywords internal
wide_to_long_trimmed_windows <- function(wide_file_windows_trimmed, start_prefix_name = "start", end_prefix_name = "end") {
  # Identification of the date columns defining the start and end of a window
  windows_start <- names(wide_file_windows_trimmed)[stringr::str_detect(names(wide_file_windows_trimmed), paste0("^", start_prefix_name))]
  windows_end <- names(wide_file_windows_trimmed)[stringr::str_detect(names(wide_file_windows_trimmed), paste0("^", end_prefix_name))]
  if(length(windows_start) == 0 | length(windows_end) == 0){
    stop("start_prefix and/or end_prefix not found in the wide formatted input")
  }
  # Identification of the variables that are not dates
  id_vars <- names(wide_file_windows_trimmed)[!names(wide_file_windows_trimmed) %in% c(windows_start, windows_end)]

  # Transformation from wide to long format
  intermediate_long_file_windows_trimmed <- data.table::melt(wide_file_windows_trimmed, id.vars = id_vars, measures.vars = c(windows_start, windows_end))

  # Splitting the variable column to identify whether the row has a start or end value of a window
  intermediate_long_file_windows_trimmed[, c("type", "WindowName") := data.table::tstrsplit(sub("_", " ", variable), " ")][, variable := NULL]

  # Casting to long format but only the date values
  long_file_windows_trimmed <- data.table::dcast(intermediate_long_file_windows_trimmed, ... ~ factor(type, levels = c(start_prefix_name, end_prefix_name)), value.var = "value")

  return(long_file_windows_trimmed)
}
