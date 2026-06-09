#' Execute Self Controlled Risk Interval Analysis (SCRI) Pipeline
#'
#' The `scri()` function is an all-in-one workflow that automatically executes
#' all core SCRI steps, including validation, window computation, data
#' preparation, and model fitting.
#'
#' @param study_population A `data.table` with one row per individual and relevant date columns. Must include the reference date(s) and follow-up criteria.
#' @param windows_metadata A `data.table` describing exposure and control windows, their types, and how they are anchored to the study population.
#' @param records_table A `data.table` with the records related to the outcomes. This is composed by id, date and value of the record.
#' @param reference_date_name A character vector indicating which column(s) in the study population to use as index date(s).
#' @param start_followup_criteria A character vector of column names defining when follow-up starts.
#' @param end_followup_criteria A character vector of column names defining when follow-up ends. These will be used for censoring and trimming windows.
#' @param only_first_date A boolean indicating whether to only use the first date. Default is FALSE.
#' @param save_intermediate A path to a folder where the different intermediat file are saved
#' @export
#'
#' @details
#' The function performs several internal steps:
#' \itemize{
#'   \item Validates that the structure and content of `study_population` and `windows_metadata` are correctly defined
#'   \item Computes exposure and control windows based on the provided metadata
#'   \item Trims windows using censoring criteria from `end_followup_criteria`
#' }
#'
#' If needed, users can also run the validation helpers independently:
#' `validate_study_population()` and `validate_windows_metadata()`.
#'
#' Note: The column name `int_censdate` is reserved for internal use. The function will stop if it is included in `end_followup_criteria`.
#'
#' @return An object representing the cleaned set of windows for each individual (typically a `data.table`). The structure depends on downstream internal processing steps.
#'
#' @examples
#' \dontrun{
#' result <- scri(
#'   study_population = StudyPopulation,
#'   windows_metadata = WindowsMetadata,
#'   records_table = RecordsTable,
#'   reference_date_name = "FIRST_TARGET",
#'   start_followup_criteria = "op_start_date",
#'   end_followup_criteria = c("death_date", "general_end_fup")
#' )
#' }
#'
scri <- function(study_population,
                 windows_metadata,
                 records_table,
                 time_varying_table = NULL,
                 reference_date_name,
                 reference_window,
                 start_followup_criteria,
                 end_followup_criteria,
                 strata_column_name = NULL,
                 only_first_date = TRUE,
                 save_intermediate = NULL) {
  # Check input
  if (!is.logical(only_first_date) || length(only_first_date) != 1) {
    stop("`only_first_date` must be a single logical (TRUE or FALSE).")
  }

  # Check that save_intermediate is either NULL or a valid existing directory path
  if (!is.null(save_intermediate)) {
    if (!is.character(save_intermediate) || length(save_intermediate) != 1) {
      stop("`save_intermediate` must be a single string (path to a directory) or NULL.")
    }
    if (!dir.exists(save_intermediate)) {
      stop(paste("Directory does not exist:", save_intermediate))
    }
  }
  # i create a temporary column called censdate, so be sure not to overwrite it
  if ("int_censdate" %in% end_followup_criteria) {
    stop("int_censdate is a protected column name")
  }

  # Check StudyPopulations dataset
  SCRI:::validate_study_population(
    data = study_population,
    reference_date_name = reference_date_name,
    strata_column_name = strata_column_name,
    extra_date_columns = c(start_followup_criteria, end_followup_criteria)
  )
  # Check WindowsMetadataDataset
  SCRI:::validate_windows_metadata(windows_metadata)
  # Rename anchor names
  result_rename <- SCRI:::rename_anchor(study_population, reference_date_name)
  study_population <- result_rename$data
  reference_date_name <- result_rename$new_names

  # Compute windows for each person
  scri_computed_windows <- SCRI:::construct_windows(
    study_population = study_population,
    windows_metadata = windows_metadata,
    reference_date_name = reference_date_name
  )
  if (!is.null(save_intermediate)) {
    data.table::fwrite(scri_computed_windows, file = file.path(save_intermediate, "scri_computed_windows.csv"))
  }
  # Validate computation of windows
  SCRI:::validate_construct_windows(scri_computed_windows, windows_metadata)
  # Trim windows with censoring criteria and overlapping windows
  scri_computed_windows_cleaned <- SCRI:::wrangle_window(scri_computed_windows, end_followup_criteria)
  if (!is.null(save_intermediate)) {
    data.table::fwrite(scri_computed_windows_cleaned, file = file.path(save_intermediate, "scri_computed_windows_cleaned.csv"))
  }

  # Identify the outcomes that occurred within each window after they have been altered or cleaned.
  scri_indentified_records <- SCRI:::add_records(scri_computed_windows_cleaned, records_table, only_first_date)
  if (!is.null(save_intermediate)) {
    data.table::fwrite(scri_indentified_records, file = file.path(save_intermediate, "scri_indentified_records.csv"))
  }
  # TODO Add time-varying variables

  # QUESTIONS: WHEN SHALL THIS BE APPLIED? Before or after identitifying the records that fall within the windows?
  if (!is.null(time_varying_table)) {
    scri_indentified_records <- SCRI:::apply_timevarying(scri_indentified_records, time_varying_table)
    if (!is.null(save_intermediate)) {
      data.table::fwrite(scri_indentified_records, file = file.path(save_intermediate, "scri_indentified_records_timevar.csv"))
    }
  }

  # Add strata_columns to the results
  scri_analytical_dataset <- SCRI:::prepare_analytical_dataset(
    scri_identified_records = scri_indentified_records,
    strata_column_name = strata_column_name,
    only_first_date = only_first_date
  )
  if (!is.null(save_intermediate)) {
    data.table::fwrite(scri_analytical_dataset, file = file.path(save_intermediate, "scri_analytical_dataset.csv"))
  }

  # Apply analysis
  results_analysis <- SCRI:::apply_analysis(
    scri_analytical_dataset = scri_analytical_dataset,
    reference_window = reference_window,
    strata_column_name = strata_column_name
  )
  if (!is.null(save_intermediate)) {
    data.table::fwrite(results_analysis, file = file.path(save_intermediate, "results_analysis.csv"))
  }

  # print_scri_results(res)
  return(results_analysis)
}

# TODO
# - Create list of features of the package
# - Pick some papers and filal up the metadata input
# Find empyrical papers with SCRI SCCS and
# sofie bots pericaridtis and myorcaridits
