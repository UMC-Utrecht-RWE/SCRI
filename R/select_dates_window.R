#' Select Dates Window
#'
#' This function identifies all records within the records_table that fall within a window specified in the scri_trimmed table in the start and end columns.
#'
#' @param variable_name The name of the variable.
#' @param window_name The name of the window.
#' @param records_table The record table of interest, minimum expected columns are: person_id, date, value.
#' @param scri_trimmed The trimmed scri.
#' @param start_window_date_col_name The start date column name in the scri_trimmed. Default is "start".
#' @param end_window_date_col_name The end date column name in the scri_trimmed. Default is "end".
#' @param only_first_date A boolean indicating whether to only use the first date. Default is FALSE.
#' @return A data table with the result of the query.
#' @export
#'
select_dates_window <- function(variable_name,
                                window_name,
                                records_table, # record table of interest, minimum expected columns are: person_id, date, value
                                scri_trimmed,
                                start_window_date_col_name, # column name
                                end_window_date_col_name, # column name
                                only_first_date = FALSE) {
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
    "SELECT DISTINCT t1.person_id, t2.date, (t1.", end_window_date_col_name, " - t1.", start_window_date_col_name, ")
                    AS  WindowLength, t1.", start_window_date_col_name, " AS START_DATE, t1.", end_window_date_col_name, " AS END_DATE",
    " FROM scri_trimmed t1",
    " INNER JOIN records_table t2",
    " ON (t1.person_id = t2.person_id
          AND (t2.date BETWEEN t1.", start_window_date_col_name, " AND t1.", end_window_date_col_name, ") AND window_name == '",window_name,"')",
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
