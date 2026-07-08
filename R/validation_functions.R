#' Validate a study population structure
#'
#' @param data A StudyPopulation dataset
#' @param extra_date_columns A list of extra date columns
#' @keywords internal

validate_study_population <- function(data, reference_date_name, strata_column_name = NULL, extra_date_columns = NULL) {
  assertthat::assert_that(data.table::is.data.table(data), msg = "StudyPopulation must be a data table")

  # Only include non-null columns
  required_cols <- c("id", reference_date_name)
  if (!is.null(extra_date_columns)) required_cols <- c(required_cols, extra_date_columns)

  # Check required columns exist
  missing_cols <- required_cols[!required_cols %in% colnames(data)]
  assertthat::assert_that(length(missing_cols) == 0,
    msg = paste0("StudyPopulation is missing required columns: ", paste(missing_cols, collapse = ", "))
  )

  # Check column types
  assertthat::assert_that(is.character(data$id), msg = "StudyPopulation: Column 'id' must be character")

  # Validate dynamic date columns
  if (!is.null(reference_date_name)) {
    invisible(lapply(reference_date_name, function(col_name) {
      assertthat::assert_that(inherits(data[[col_name]], "Date"),
        msg = paste0("StudyPopulation: Reference date column '", col_name, "' must be Date")
      )
    }))
  }

  # Validate strata columns
  if (!is.null(strata_column_name)) {
    invisible(lapply(strata_column_name, function(col_name) {
      assertthat::assert_that(
        inherits(data[[col_name]], "character") || is.numeric(data[[col_name]]),
        msg = paste0("StudyPopulation: Strata column '", col_name, "' must be numeric or character")
      )
      assertthat::assert_that(
        all(!is.na(data[[col_name]])),
        msg = paste0("StudyPopulation: Strata column '", col_name, "' contains missing (NA) values")
      )
    }))
  }

  # Validate dynamic date columns
  if (!is.null(extra_date_columns)) {
    invisible(lapply(extra_date_columns, function(col_name) {
      assertthat::assert_that(inherits(data[[col_name]], "Date"),
        msg = paste0("Column '", col_name, "' must be Date")
      )
    }))
  }
}


#' Validate Windows Metadata information
#'
#' This function checks if the WindowMetadata inputed in the function is correctly
#' @param data A WindowMetadata
#' @param error_on_overlap TRUE when we want to stop executing if there is an overlap between windows
#' @keywords internal

validate_windows_metadata <- function(data, error_on_overlap = FALSE) {
  assertthat::assert_that(data.table::is.data.table(data),
    msg = "WindowMetadata must be a data.table"
  )

  if (!data.table::is.data.table(data)) data <- as.data.table(data) # convert if necessary

  required_cols <- c("outcome", "window_name", "start_window", "length_window")
  missing_cols <- required_cols[!required_cols %in% colnames(data)]
  assertthat::assert_that(length(missing_cols) == 0,
    msg = paste0("WindowMetadata is missing required columns: ", paste(missing_cols, collapse = ", "))
  )

  # Column type checks
  assertthat::assert_that(is.character(data$outcome), msg = "WindowMetadata: Column 'outcome' must be character")
  assertthat::assert_that(is.character(data$window_name), msg = "WindowMetadata: Column 'window_name' must be character")
  assertthat::assert_that(is.numeric(data$start_window), msg = "WindowMetadata: Column 'start_window' must be numeric")
  assertthat::assert_that(is.numeric(data$length_window), msg = "WindowMetadata: Column 'length_window' must be numeric")

  # Compute absolute start and end of windows (assuming start_date = reference_date_name + start_window, and end_date = start_date + length_window - 1)
  data[, start := start_window]
  data[, end := start_window + length_window - 1]

  # Check for overlapping windows within each group
  overlaps_found <- data[,
    {
      dt <- data.table::copy(.SD)
      data.table::setorder(dt, start)
      dt[, `:=`(
        previous_end = data.table::shift(end, type = "lag", fill = -Inf),
        previous_window = data.table::shift(window_name, type = "lag")
      )]
      dt[previous_end >= start, .(
        overlapping_windows = paste(previous_window, "and", window_name),
        start, end,
        previous_end
      )]
    },
    by = .(outcome)
  ]

  if (nrow(overlaps_found) > 0) {
    overlap_report <- overlaps_found[, paste0(
      "outcome = ", outcome,
      " are overlapping on: ", overlapping_windows
    )]

    msg <- paste0(
      "Overlapping windows detected:\n",
      paste(overlap_report, collapse = "\n")
    )

    if (error_on_overlap) {
      stop(msg)
    } else {
      warning(msg)
    }
  }
  data[, start := NULL][, end := NULL]
}

#' Validate Windows Metadata information
#'
#' This function checks if the sp_windows_object has been computed accordingly
#' @param sp_windows_object Result from the construct_window step
#' @param windows_metadata A WindowMetadata
#' @keywords internal
#'
validate_construct_window <- function(sp_windows_object, windows_metadata) {
  window_names <- unique(windows_metadata$window_name)

  start_end_names <- identify_start_end_cols(sp_windows_object)
  # check that all window names have a start and end, if not throw an error
  if (!all(sub("start_", "", start_end_names$start_names) %in% window_names) && all(window_names %in% sub("end_", "", start_end_names$end_names))) {
    stop("not all windows have a start and end, or start/end is used for a different column name. Check input object details")
  }
}


#' Validate Model to be used
#'
#' This function validates model_name against the valid models for SCRI.
#' @keywords internal
validate_model_name <- function(model_name) {
  ValidModels <- get_ValidModels()
  if (is.null(model_name)) {
    model_name <- get_DefaultModels()
    message(paste0("Model name empty. Selected as default model: ", model_name))
  }
  assertthat::assert_that(is.character(model_name),
    msg = "Input 'model_name' must be character"
  )
  assertthat::assert_that(any(model_name %in% ValidModels$model_name),
    msg = "Invalid 'model_name' inputted. Use get_ValidModels() for more details"
  )
}
