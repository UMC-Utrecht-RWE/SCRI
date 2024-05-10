#' Compute start and end window dates for each individual in a study population based on metadata info. First step of the SCRI pipeline
#'
#' @param studypopulation data frame containing one row per unit of observation, reference date column specified in windowmeta, any other information
#' @param windowmeta metadatat file specifying window names/types, reference date columns, start and length of windows (see details)
#' @param id_column column name identifying the unique unit of observation in the study population
#' @param output_format "wide" or "long" see details
#'
#' @return a data.table object with the same columns as studypopulation, plus start_ and end_ window dates for each window type supplied in windowmeta
#' @export
#' @importFrom data.table :=
#' @examples studypop <- readRDS(system.file("extdata", "StudyPopulation.rds", package = "SCRI"))
#'           windowmet <- readRDS(system.file("extdata", "WindowsMetadata.rds", package = "SCRI"))
#'           SCRI::compute_windows(studypop, windowmet)
compute_windows <- function(studypopulation, windowmeta,
                            id_column = "person_id",
                            output_format = "wide"){

  # takes as input the studypopulation and produces as output a wide format dataset
  # re-write studypopulation to data.table
  studypopulation <- data.table::as.data.table(studypopulation)

  # column names to lower cases
  colnames(windowmeta) <- tolower(colnames(windowmeta))

  # first, check if necessary columns are supplied
  meta_check <- c("window_name","reference_date","start_window","length_window") %in% colnames(windowmeta)
  if(!all(meta_check) == TRUE){
    stop(paste0("Error: expected input columns ", meta_check[meta_check != TRUE], " missing from windowmeta input object"))
  }

  # check if all reference dates supplied are columns in studypopulaiton
  date_cols <- (unique(windowmeta$reference_date))
  ref_check <- date_cols %in% colnames(studypopulation)
  if(!all(ref_check) == TRUE){
    stop(paste0("Error: expected reference_date columns ", ref_check[ref_check != TRUE], " missing from studypopulation input object"))
  }
  # re-write to date format
  studypopulation[, (date_cols) := lapply(.SD, as.Date), .SDcols = date_cols]

  # transform into a longer shape dataset (takes care of multiple reference date entries)
  studypop_long <- data.table::melt(studypopulation, id.vars = "person_id",
                   measure.vars = unique(windowmeta$reference_date),
                   variable.name = "reference",
                   value.name = "reference_date",
                   unique = TRUE)
  # add back columns
  studypop_long <- merge(studypop_long, studypopulation, by = id_column)
  # omit duplicate date information
  studypop_long <- studypop_long[,(date_cols):= NULL]

  # merge with scri metadata to get the window information
  studypop_long <- merge(studypop_long, windowmeta,
                         by.x = c("reference"), by.y = c("reference_date"), allow.cartesian = TRUE)


  # calculate start and end date of each window
  studypop_long[, start := reference_date + as.numeric(start_window)]
  studypop_long[, end := start + as.numeric(length_window) - 1]

  # for qc purposes, may be desirable to output this intermediary object in long format
  if(output_format == "long"){
    return(studypop_long)
  }else if(output_format == "wide"){
  # typically we will want the wide format output instead to vectorize trimming and merging rules
    # first cast from long to wide
    studypop_wide <- data.table::dcast(studypop_long, person_id ~ window_name, value.var = c("start", "end"))

    # then merge with the input object
    studypop_wide_output <- base::merge(studypopulation, studypop_wide, by = id_column, all.x = TRUE)

    # return output
    return(studypop_wide_output)
  }

}
