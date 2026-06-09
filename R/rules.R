# Basic rule functions

#' Rule: Ensure windows do not overlap
#'
#' @param windows A list of Window objects.
#' @return TRUE if no overlap detected, otherwise an error is thrown.
#' @keywords internal

check_no_overlap <- function(windows) {
  for (i in seq_along(windows)) {
    for (j in seq_along(windows)) {
      if (i != j &&
        windows[[i]]$start_date <= windows[[j]]$end_date &&
        windows[[i]]$end_date >= windows[[j]]$start_date) {
        print("Overlap detected.")
        stop("Windows cannot overlap.")
      }
    }
  }
  print("No overlap detected.")
  TRUE
}

#' Rule: Ensure start dates are before end dates
#'
#' @param windows A list of Window objects.
#' @return TRUE if all start dates are before or on the end dates.
#' @keywords internal
check_start_before_end <- function(windows) {
  invalid_windows <- sapply(windows, function(w) w$start_date > w$end_date)
  if (any(invalid_windows)) {
    print("Start date after end date detected.")
    stop("All start dates must be before or equal to end dates.")
  }
  print("All start dates are valid.")
  TRUE
}

# Rule registry for SCRI
rule_registry <- list(
  scri = list()
)

#' Add a rule to SCRI
#'
#' @param design The study design. Must be "scri".
#' @param rule The rule function.
#' @keywords internal
add_rule <- function(design, rule) {
  if (design != "scri") {
    stop("Only 'scri' design is supported.")
  }
  if (!design %in% names(rule_registry)) {
    rule_registry[[design]] <- list()
  }
  rule_registry[[design]] <- append(rule_registry[[design]], list(rule))
}
