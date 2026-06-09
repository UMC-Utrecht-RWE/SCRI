#' Compute start and end window dates for each individual in a study population based on metadata info. First step of the SCRI pipeline
#'
#' @param study_population data frame containing one row per unit of observation, reference date column specified in windows_metadata, any other information
#' @param windows_metadata metadatat file specifying window names/types, reference date columns, start and length of windows (see details)
#' @param id_column column name identifying the unique unit of observation in the study population
#'
#' @export
#' @return a data.table object with the same columns as study_population, plus start_ and end_ window dates for each window type supplied in windows_metadata
#' @importFrom data.table :=

construct_windows <- function(study_population, windows_metadata, reference_date_name,
                            id_column = "id"){

  studypop_long <- data.table::melt(study_population, id.vars = id_column,
                                     measure.vars = unique(reference_date_name),
                                     variable.name = c("reference_date_name"),
                                     value.name = "reference_date",
                                     unique = TRUE)
  # add back columns
  studypop_long <- data.table::merge.data.table(studypop_long, study_population, by = id_column)
  
  # Convert to data.table
  reference_date_table <- data.table::data.table(reference_date_name)
  # Add a dummy key column to both
  reference_date_table[, key := 1]
  windows_metadata[, key := 1]
  
  # Now perform the cross join
  windows_metadata <- data.table::merge.data.table(
    windows_metadata, 
    reference_date_table, 
    by = 'key',  # This means no matching columns (cross join)
    allow.cartesian = TRUE
  )
  windows_metadata[, key := NULL]

  # merge with scri metadata to get the window information
  studypop_long <- data.table::merge.data.table(studypop_long, windows_metadata,
                         by = c("reference_date_name"), allow.cartesian = TRUE)

  # calculate start and end date of each window
  studypop_long[, start := reference_date + as.numeric(start_window)]
  studypop_long[, end := start + as.numeric(length_window) - 1]

  studypop_wide <- data.table::dcast(studypop_long
                                     , formula = as.formula(paste(id_column, "+ outcome ~ window_name + reference_date_name"))
                                     , value.var = c("start", "end"))

  # then merge with the input object
  studypop_wide_output <- data.table::merge.data.table(study_population, studypop_wide, by = id_column, all.x = TRUE)

  # return output
  return(studypop_wide_output)

}
