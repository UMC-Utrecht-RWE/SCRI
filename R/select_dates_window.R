#' Select Dates Window
#'
#' This function uses identifies all (by default) the records within the records_table that fall within a window specified in the scri_trimmed table
#'
#' @param variable_name The name of the variable.
#' @param window_name The name of the window.
#' @param records_table The record table of interest, minimum expected columns are: person_id, date, value.
#' @param scri_trimmed The trimmed scri.
#' @param only_first_date A boolean indicating whether to only use the first date. Default is FALSE.
#' @param windows_of_interest The windows of interest. Default is NULL.
#' @param scri_trimmed_start_prefix The start prefix for the scri_trimmed. Default is "start".
#' @param scri_trimmed_end_prefix The end prefix for the scri_trimmed. Default is "end".
#' @return A data table with the result of the query.
#' @export
select_dates_window <- function(variable_name,
                                window_name,
                                records_table,
                                scri_trimmed,
                                scri_trimmed_start_prefix = "start",
                                scri_trimmed_end_prefix = "end",
                                only_first_date = FALSE,
                                windows_of_interest = NULL,
                                ) {

  scri_trimmed <- wide_to_long_trimmed_windows(scri_trimmed, start_prefix = scri_trimmed_start_prefix, end_prefix = scri_trimmed_start_prefix)
  if (!is.null(windows_of_interest)) {
    scri_trimmed <- scri_trimmed[WindowName %in% windows_of_interest]
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
    "SELECT DISTINCT t1.person_id, t2.date, (t1.END_DATE - t1.START_DATE)
                    AS  WindowLength, t1.START_DATE, t1.END_DATE",
    " FROM scri_trimmed t1",
    " INNER JOIN records_table t2",
    " ON (t1.person_id = t1.person_id
          AND (t2.date BETWEEN t1.START_DATE AND t1.END_DATE",
    ")",
    ")",
    only_first_date_part2
  )


  result_query_dt <- as.data.table(sqldf(query))

  return(result_query_dt)
}

wide_to_long_trimmed_windows <- function(wide_file_windows_trimmed, start_prefix, end_prefix) {
  # This function takes windows_trimmed in a wide format and transforms it in a long format

  # Identification of the date columns defining the start and end of a windown
  windows_start <- names(wide_file_windows_trimmed)[str_detect(names(wide_file_windows_trimmed), paste0("^", start_prefix))]
  windows_end <- names(wide_file_windows_trimmed)[str_detect(names(wide_file_windows_trimmed), paste0("^", end_prefix))]

  id_vars <- names(wide_file_windows_trimmed)[!names(wide_file_windows_trimmed) %in% c(windows_start, windows_end)]
  intermediate_long_file_windows_trimmed <- melt(wide_file_windows_trimmed, id.vars = id_vars, measures.vars = c(windows_start, windows_end)) # From wide to long
  intermediate_long_file_windows_trimmed[type %in% start_prefix, type := 'START_DATE']#renaming values of type to START_DATE and END_DATE
  intermediate_long_file_windows_trimmed[type %in% end_prefix, type := 'END_DATE']
  intermediate_long_file_windows_trimmed[, c("type", "WindowName") := tstrsplit(sub("_", " ", variable), " ")][, variable := NULL] # We need to split to identify whether the row has a start or end value of a window
  long_file_windows_trimmed <- dcast(intermediate_long_file_windows_trimmed, ... ~ type, value.var = "value") # casting to long but only the date values
  return(long_file_windows_trimmed)
}
