#' Clean the start and end dates of windows created by construct_windows() based on censoring dates
#'
#' @param sp_windows_object data.table object containing named start and end date columns, typically output of construct_windows()
#' @param censoring_dates column name(s) of censoring dates
#'
#' @return object of the same dimensions and type as the input, with end dates possibly censored
#' @importFrom data.table :=
#' @export
#' 
wrangle_window <- function(sp_windows_object,
                           censoring_dates = c("death_date", "general_end_fup")
                           # TODO: winning-dose rule metadata
) {
  
  # TODO:
  # The example code in the readme for SCRI::construct_windows does not work, needs update.
  # Understand why you used '_post' in the column names, but it is confusing. Consider changing.
  
  # obtain window names (assumes input is data.table, has this naming convention for columns)
  start_end_names <- SCRI:::identify_start_end_cols(sp_windows_object)
  start_names <- start_end_names$start_names
  end_names <- start_end_names$end_names
  
  # create a matrix which is an ordered set of window start-end pairs form earliest to latest
  # first, check that all columns are the same rank
  # TODO: whats the purpose of this? wouldnt the order in window meta data give the information you need here?
  col_ranks <- apply(sp_windows_object[,..start_names],1, rank)
  if(!all(col_ranks == col_ranks[,1])){
    stop("current functionality assumes the same ordering of windows within each individual")
  }
  # then create the matrix of window start-end-pairs
  start_names_ordered <- names(col_ranks[,1])
  window_pairs <- cbind(start_names_ordered,paste0("end_",sub("start_","",start_names_ordered)))
  colnames(window_pairs) <- c("start","end")
  
  
  #=== Trimming starts ===
  # Let's say we have doses from FRIST_TARGET to {N}_TARGET and windows in col_ranks
  # 1. Check whether {N}_TARGET < end_{window}_{N-1}
  #   1.1) The order of trimming should follow the order of {window}. 
  #      eg. if the window order is risk-washout-control, start with trimming when {N}_TARGET < end_risk_{N-1}
  #   1.2) Trim the overlappign windows based on the matrix input (ie. which dose win? later vs. earlier); from dose 1 to N
  #     1.2.1) if later dose win: replace end_{window}_{N-1} to {N}_TARGET - 1
  #            if earlier does win: replace start_{window}_{N} to end_{window[col_ranks - 1]}_{N-1} + 1
  #
  # 
  # for (dose in 1:N){
  #   for (window in col_ranks) {
  #     if(LaterDoseWin) {
  #       sp_windows_object[{N}_TARGET < end_{window}_{N-1}, 
  #                         end_{window}_{N-1} := {N}_TARGET - 1]
  #     }
  #     if(EarlierDoseWin) { 
  #       sp_windows_object[{N}_TARGET < end_{window}_{N-1}, 
  #                         start_{window}_{N} := end_{window[col_ranks - 1]} - 1]
  #     }
  #   }
  # }
  #
  # 2. Apply the global censoring rule (eg death, general_end_fup)
  #   2.1) create internal censoring date columns
  #         we will use this for censoring window-by-window
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
  
  #   2.2) censor windows as follows:
  #         if an event happens between a start and end pair, the end date is reset to the censoring date, all future window dates are NA
  #         if an event happens not between a start and end pair, then set all windows afterwards to NA
  for (i in 1:nrow(window_pairs)) {
    start_col <- window_pairs[i,"start"]
    end_col <- window_pairs[i,"end"]
    
    # Update 'end' column value if event between start and end to date of censoring event
    sp_windows_object[int_censdate >= get(start_col) & int_censdate < get(end_col),
                      (end_col) := int_censdate]
    
    # set start and end to NA if the censoring event happens before the start window (by necessity then also before the end)
    sp_windows_object[int_censdate < get(start_col),
                      c(start_col, end_col) := NA]
    
    # 
  }
  
  # remove internal censoring date column
  sp_windows_object[,int_censdate := NULL]
  
  
  # 3. Chek if end_{window}_{n} < start_{window}_{n}; if so, set both both dates to NA.

  
  return(sp_windows_object)
  
}


