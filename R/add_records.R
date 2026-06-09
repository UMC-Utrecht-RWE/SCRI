#' Select Dates Window
#'
#' This function identifies all records within the records that fall within a window specified in the window_data table in the start and end columns.
#'
#' @param window_data The input data object recording start/end dates of each window per person, after trimming and cleaning. May be a wide or long format, output of wrangle_window
#' @param records A data table containing records with at minimum: id, date, value columns.
#' @param only_first_record Logical. If TRUE, only keeps the first record per person. Default is FALSE.
#' @param is_wide_format Logical. If TRUE, input window_data is in wide format and needs conversion. Default is TRUE.
#' @param start_column_prefix A string for the prefix of start date columns in wide format. Default is "start".
#' @param end_column_prefix A string for the prefix of end date columns in wide format. Default is "end".
#' @return A data table with the result of the query.
#'
#' @export
#'

add_records <- function(window_data,
                        records, # record table of interest, minimum expected columns are: id, date, value
                        only_first_record = TRUE,
                        is_wide_format = TRUE,
                        start_column_prefix = "start",
                        end_column_prefix = "end") {
  # Convert to long format if needed
  window_data <- if (is_wide_format) {
    SCRI:::melt_window_data(
      window_data = window_data,
      start_column_prefix = start_column_prefix,
      end_column_prefix = end_column_prefix
    )
  } else {
    window_data
  }

  # Prepare SQL components based on first record requirement
  rank_clause <- if (only_first_record) {
    ",ROW_NUMBER() OVER (PARTITION BY id ORDER BY date ASC) AS record_rank"
  } else {
    ""
  }

  filter_clause <- if (only_first_record) {
    "WHERE record_rank = 1"
  } else {
    ""
  }

  # Build query to find events within time windows
  query <- paste0(
    "SELECT id, outcome, window_name, window_length, date, start_date, end_date
    FROM (
      SELECT *", rank_clause, "
      FROM (
        SELECT DISTINCT
          t1.id,
          t2.date,
          t1.outcome,
          t1.window_name,
          (t1.", end_column_prefix, " - t1.", start_column_prefix, ") AS window_length,
          t1.", start_column_prefix, " AS start_date,
          t1.", end_column_prefix, " AS end_date
        FROM window_data t1
        INNER JOIN records t2
        ON t1.id = t2.id
           AND t2.date BETWEEN t1.", start_column_prefix, " AND t1.", end_column_prefix, "
           AND t1.outcome = t2.outcome
      )
    )", filter_clause
  )

  # Execute query and convert date columns
  results <- data.table::as.data.table(sqldf::sqldf(query))

  # Convert date columns from numeric to Date type
  date_columns <- c("date", "start_date", "end_date")
  for (col in date_columns) {
    if (col %in% names(results)) {
      results[, (col) := as.Date(get(col), origin = "1970-01-01")]
    }
  }

  results <- data.table::merge.data.table(window_data, results, by.x = c("id", "outcome", "window_name", start_column_prefix, end_column_prefix), by.y = c("id", "outcome", "window_name", "start_date", "end_date"), all = TRUE)
  results[is.na(date), window_length := get(end_column_prefix) - get(start_column_prefix)]
  return(results)
}

#' melt_window_data
#'
#' This function takes windows_trimmed in a wide format and transforms it in a long format.
#'
#' @param window_data A data table in wide format.
#' @param start_column_prefix A string that defines the prefix for the start of a window. Default is "start".
#' @param end_column_prefix A string that defines the prefix for the end of a window. Default is "end".
#'
#' @return A data table in long format.
#'
#' @importFrom data.table .SD
#' @export
melt_window_data <- function(window_data, start_column_prefix = "start", end_column_prefix = "end") {
  # Identification of the date columns defining the start and end of a window
  windows_start <- names(window_data)[stringr::str_detect(names(window_data), paste0("^", start_column_prefix))]
  windows_end <- names(window_data)[stringr::str_detect(names(window_data), paste0("^", end_column_prefix))]
  if (length(windows_start) == 0 | length(windows_end) == 0) {
    stop("start_prefix and/or end_prefix not found in the wide formatted input")
  }
  # Identification of the variables that are not dates
  id_vars <- names(window_data)[!names(window_data) %in% c(windows_start, windows_end)]

  # Transformation from wide to long format
  long_window_data <- data.table::melt(window_data, id.vars = id_vars, measures.vars = c(windows_start, windows_end))

  # Splitting the variable column to identify whether the row has a start or end value of a window
  long_window_data[, c("type", "window_name") := data.table::tstrsplit(sub("_", " ", variable), " ")][, variable := NULL]

  # Casting to long format but only the date values
  long_window_data <- data.table::dcast(long_window_data,
    ... ~ factor(type, levels = c(start_column_prefix, end_column_prefix)),
    value.var = "value"
  )

  return(long_window_data)
}
