#' Compute Summary Statistics for SCRI Model
#'
#' Computes count-based metrics and unadjusted incidence rate ratios (IRRs) for each
#' exposure window in a Self-Controlled Analysis (SCRI) framework. Uses conditional
#' logistic regression to estimate IRRs, comparing event rates across windows.
#'
#' @param SCRI_analytical_dataset A `data.table` containing the analytical dataset,
#' including the `event`, `length`, `window_name`, and `person_id` columns.
#' @param i_outcome A character string naming the AESI or i_outcome of interest.
#' @param ... Additional arguments passed to `survival::clogit()`.
#'
#' @return A named vector containing event counts, person-time, and IRR estimates
#' (with confidence intervals) for each comparison window.
#'
#' @details This function assumes a reference window named `"control"`. If there are
#' no events in either the reference or comparison window, or if model fitting fails,
#' a placeholder value of -88 is returned.
#'
#' @examples
#' \dontrun{
#' stats <- compute_SCRI_stats(my_data, i_outcome = "my_outcome")
#' }
#' @export
#'
compute_SCRI_stats <- function(SCRI_analytical_dataset, reference_window,
                               i_outcome) {
  # Get unique window names from the dataset
  unique_windows <- unique(SCRI_analytical_dataset$window_name)

  # Create an empty list to store results
  count_res <- list("outcome" = i_outcome)

  # ======== COUNT ========#
  # Loop through each window name and calculate statistics
  for (window in unique_windows) {
    window_data <- SCRI_analytical_dataset[SCRI_analytical_dataset$window_name == window, ]

    # Calculate statistics for this window
    n_event <- sum(window_data$event)
    time_sum <- sum(window_data$length)

    # Store results with dynamic names
    count_res[[paste0("n_event_", window)]] <- n_event
    count_res[[paste0("time_", window)]] <- time_sum
  }
  # Convert list to named vector if needed
  # count_res <- unlist(count_res)

  # ======== UNADJUSTED IRR ========#
  # create model statements
  crudemodel_chr <- as.formula(paste0("event ~ window_name + strata(id) + offset(log_length)"))

  # compute crude/unadjusted model
  clean_data <- na.omit(SCRI_analytical_dataset[, c("id", "window_name", "event", "log_length")])

  crmod <- log_reg(crudemodel_chr, "crude", i_outcome, clean_data)

  # Let's say we're comparing each window against a reference window
  comparison_windows <- setdiff(unique_windows, reference_window)

  # Create an empty list to store results
  all_results <- list()

  # Process each comparison window
  for (comp_window in comparison_windows) {
    # Get the event counts for this comparison
    n_event_comp <- count_res[paste0("n_event_", comp_window)][[1]]
    n_event_ref <- count_res[paste0("n_event_", reference_window)][[1]]

    if (n_event_comp == 0 | n_event_ref == 0) {
      print(paste0("[SCRI] No events in ", comp_window, " or ", reference_window, " windows for ", i_outcome))
      window_res <- list()
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window)]] <- -88
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window, "_lowci")]] <- -88
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window, "_upci")]] <- -88
    } else if (is.character(crmod)) { # is.character(crmod[[comp_window]])
      # If this is character string then a warning or error has occurred
      print(paste0(
        "[SCRI] for ", comp_window, " vs ", reference_window, " model, ",
        i_outcome, " model fit returns ", crmod
      ))
      window_res <- list()
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window)]] <- -88
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window, "_lowci")]] <- -88
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window, "_upci")]] <- -88
    } else { # Otherwise, compute summary statistics
      unadj <- summary(crmod[[comp_window]])
      if (any(unadj$conf.int %in% c("Inf", "-Inf") == TRUE)) unadj$conf.int[, ] <- -88

      window_res <- list()
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window)]] <- unadj$conf.int[1]
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window, "_lowci")]] <- unadj$conf.int[3]
      window_res[[paste0("irr_", comp_window, "_vs_", reference_window, "_upci")]] <- unadj$conf.int[4]
    }

    # Add results to the main results list
    all_results <- c(all_results, window_res)
  }


  fin_res <- c(
    count_res,
    unlist(all_results)
  )

  return(fin_res)
}


#' @param model_formula The formula to use in the model
#' @param model_type Type of model being fitted
#' @param outcome Outcome variable
#' @param data Dataset to use for modeling
#'
#' @importFrom survival clogit strata
#' @import survival
#'
#' @return A conditional logistic regression model
#' @keywords internal
log_reg <- function(model_formula, model_type, outcome, data) {
  tryCatch(
    {
      survival::clogit(formula = model_formula, data = data)
    },
    error = function(cond) {
      paste("Model fitting returning error for ", model_type, " model, ", outcome)
      conditionMessage(cond)
    },
    warning = function(cond) {
      paste("Model fitting returning warning for ", model_type, " model, ", outcome)
      conditionMessage(cond)
    }
  )
}
