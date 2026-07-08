#' Apply SCRI Analysis Across Outcomes
#'
#' This function applies Self Controlled Risk Interval Analysis (SCRI) statistics computation
#' across each unique outcome in the input analytical dataset. It prepares the data,
#' loops over outcomes, and aggregates the computed statistics.
#'
#' @param SCRI_analytical_dataset A `data.table` containing the analytical dataset,
#' including variables: `length`, `outcome`, and others required for SCRI.
#' @param reference_date_name A name of the reference date e.g.: covid_vaccine_1
#' @param reference_window A name of the window to which we want to compare this 
#' has to be a combination between window_name and reerence name e.g: clean_lookback_pre_covid_vaccine_1
#' @param strata_column_name A name of a strata column used to stratify the analysis
#' @return A data frame with the combined SCRI results for all outcomes.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' results <- apply_analysis(SCRI_data)
#' }
apply_analysis <- function(SCRI_analytical_dataset,
                           reference_date_name,
                           reference_window,
                           strata_column_name = NULL) {
  # Input validation ----
  if (!data.table::is.data.table(SCRI_analytical_dataset)) {
    stop("`SCRI_analytical_dataset` must be a data.table.")
  }

  required_columns <- c("outcome", "window_length", "window_name")
  missing_cols <- setdiff(required_columns, names(SCRI_analytical_dataset))
  if (length(missing_cols) > 0) {
    stop("Missing required column(s) in `SCRI_analytical_dataset`: ", paste(missing_cols, collapse = ", "))
  }
  if (!is.character(reference_date_name) || length(reference_date_name) != 1) {
    stop("`reference_date_name` must be a single character string.")
  }

  if (!(reference_date_name %in% unique(SCRI_analytical_dataset$reference_date_name))) {
    stop(paste0("`reference_date_name` (", reference_date_name, ") not found in `reference_date_name` column of the dataset."))
  }

  if (!is.character(reference_window) || length(reference_window) != 1) {
    stop("`reference_window` must be a single character string.")
  }

  if (!(reference_window %in% unique(SCRI_analytical_dataset$window_name))) {
    stop(paste0("`reference_window` (", reference_window, ") not found in `window_name` column of the dataset."))
  }

  if (!is.null(strata_column_name)) {
    if (!is.character(strata_column_name)) {
      stop("`strata_column_name` must be a character vector or NULL.")
    }
    invalid_strata <- setdiff(strata_column_name, names(SCRI_analytical_dataset))
    if (length(invalid_strata) > 0) {
      stop("Invalid strata column name(s): ", paste(invalid_strata, collapse = ", "))
    }
  }

  # Analysis ----
  df_res <- data.table::data.table(NULL)
  # create a log length variable to apply compute_SCRI_stats
  SCRI_analytical_dataset[, log_length := log(as.numeric(window_length))]
  SCRI_analytical_dataset[, reference_window := paste0(reference_date_name, "_", reference_window)]
  outcome_list <- unique(SCRI_analytical_dataset$outcome)

  if (!is.null(strata_column_name) && length(strata_column_name) >= 1) {
    for (i_strata in strata_column_name) {
      SCRI_analytical_dataset[, strata := get(i_strata)]
      for (i_outcome in outcome_list) {
        this_est <- compute_scri_stats(
          SCRI_analytical_dataset = SCRI_analytical_dataset[outcome %in% i_outcome],
          reference_window = reference_window,
          i_outcome = i_outcome
        )
        df_res <- rbind(df_res, this_est)
      }
    }
  } else {
    for (i_outcome in outcome_list) {
      SCRI_analytical_dataset[, strata := "1"]
      this_est <- compute_scri_stats(
        SCRI_analytical_dataset = SCRI_analytical_dataset[outcome %in% i_outcome],
        reference_window = reference_window,
        i_outcome = i_outcome
      )
      df_res <- rbind(df_res, this_est)
    }
  }

  return(df_res)
}
