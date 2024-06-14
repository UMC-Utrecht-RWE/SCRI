#' Clean the start and end dates of windows created by compute_windows() based on censoring dates
#'
#' @param sp_windows_object data.table object containing named start and end date columns, typically output of compute_windows()
#' @param censoring_dates column name(s) of censoring dates
#'
#' @return object of the same dimensions and type as the input, with end dates possibly censored
#' @export
#' @importFrom data.table :=
#'
clean_windows <- function(sp_windows_object,
                          censoring_dates = c("death_date", "general_end_fup")
                          ){

  # obtain window names (assumes input is data.table, has this naming convention for columns)
  start_names <- names(sp_windows_object)[grep("^start_", names(sp_windows_object))]
  end_names <- names(sp_windows_object)[grep("^end_", names(sp_windows_object))]

  # enforce data.table object type
  if(!data.table::is.data.table(sp_windows_object)){
    message("recoding input object to data.table, please check function documentation")
    sp_windows_object <- data.table::as.data.table(sp_windows_object)
  }

  # extract window names
  window_names <- sub("start_","",start_names)
  # check that all window names have a start and end, if not throw an error
  if(!all(sub("end_","",end_names) %in% window_names) && all(window_names %in% sub("end_","",end_names))){
    stop("not all windows have a start and end, or start/end is used for a different column name. Check input object details")
  }
  # i create a temporary column called censdate, so be sure not to overwrite it
  if("int_censdate" %in% censoring_dates){
    stop("int_censdate is a protected column name")
  }

  # create a matrix which is an ordered set of window start-end pairs form earliest to latest
    # first, check that all columns are the same rank
  col_ranks <- apply(sp_windows_object[,..start_names],1, rank)
  if(!all(col_ranks == col_ranks[,1])){
    stop("current functionality assumes the same ordering of windows within each individual")
  }
    # then create the matrix of window start-end-pairs
  start_names_ordered <- names(col_ranks[,1])
  window_pairs <- cbind(start_names_ordered,paste0("end_",sub("start_","",start_names_ordered)))
  colnames(window_pairs) <- c("start","end")

  # creaate internal censoring date columns
  # we will use this for censoring window-by-window
  if(length(censoring_dates) == 1){
    sp_windows_object[, int_censdate := censoring_dates]
  }else{

  # first extract any censoring dates
  # get minimum date per row and handle NAs
  min_date_ignore_na <- function(.SD) {
    non_na_dates <- na.omit(as.vector(unlist(.SD)))
    if(length(non_na_dates) == 0) {
      return(NA)
    } else {
      return(min(non_na_dates))
    }
  }

  # create internal censoring date
  sp_windows_object[, int_censdate := as.Date(apply(.SD, 1, min_date_ignore_na)), .SDcols = censoring_dates]
}

  # --- censor windows as follows:
  # if an event happens between a start and end pair, the end date is reset to the censoring date, all future window dates are NA
  # if an event happens not between a start and end pair, then set all windows afterwards to NA

  for (i in 1:nrow(window_pairs)) {
    start_col <- window_pairs[i,"start"]
    end_col <- window_pairs[i,"end"]

    # Update 'end' column value if event between start and end to date of censoring event
    sp_windows_object[int_censdate >= get(start_col) & int_censdate < get(end_col),
       (end_col) := int_censdate]
    # set start and end to NA if the censoring event happens before the start window (by necessity then also before the end)
    sp_windows_object[int_censdate < get(start_col),
               c(start_col, end_col) := NA]
  }

  # remove internal censoring date column
  sp_windows_object[,int_censdate := NULL]
  sp_windows_object

}


