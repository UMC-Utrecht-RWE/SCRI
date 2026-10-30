#' Clean the start and end dates of windows created by construct_window() based on censoring dates
#'
#' @param sp_windows_object data.table object containing named start and end date columns, typically output of construct_window()
#' @param censoring_dates column name(s) of censoring dates
#' @param windows_priority Optional long or MxM priority table. If NULL, the generic package configuration is used.
#'
#' @return object of the same dimensions and type as the input, with end dates possibly censored
#' @importFrom data.table :=
#' @export
#'
wrangle_window <- function(sp_windows_object,
                           censoring_dates = NULL,
                           windows_priority = NULL) {
  # obtain window names (assumes input is data.table, has this naming convention for columns)
  start_end_names <- identify_start_end_cols(sp_windows_object)
  start_names <- start_end_names$start_names
  end_names <- start_end_names$end_names

  if (length(start_names) == 0 || length(end_names) == 0) {
    stop("sp_windows_object must contain start_ and end_ window columns")
  }

  # Every start_<window> must have an end_<window> pair and vice versa.
  start_suffix <- sub("^start_", "", start_names)
  end_suffix <- sub("^end_", "", end_names)
  missing_end <- setdiff(start_suffix, end_suffix)
  missing_start <- setdiff(end_suffix, start_suffix)
  if (length(missing_end) > 0 || length(missing_start) > 0) {
    msg <- paste0(
      "sp_windows_object must contain complete start/end pairs for each window.",
      if (length(missing_end) > 0) paste0(" Missing end_ for: ", paste(missing_end, collapse = ", ")) else "",
      if (length(missing_start) > 0) paste0(" Missing start_ for: ", paste(missing_start, collapse = ", ")) else ""
    )
    stop(msg)
  }

  if (!is.null(censoring_dates)) {
    missing_censoring <- censoring_dates[!censoring_dates %in% names(sp_windows_object)]
    if (length(missing_censoring) > 0) {
      stop(
        paste0(
          "sp_windows_object is missing censoring column(s): ",
          paste(missing_censoring, collapse = ", ")
        )
      )
    }
  }

  # create a matrix which is an ordered set of window start-end pairs form earliest to latest
  # first, check that all columns are the same rank

  col_ranks <- apply(sp_windows_object[, ..start_names], 1, rank)
  if (!all(col_ranks == col_ranks[, 1])) {
    stop("current functionality assumes the same ordering of windows within each individual")
  }
  # then create the matrix of window start-end-pairs
  start_names_ordered <- names(col_ranks[, 1])
  window_pairs <- cbind(start_names_ordered, paste0("end_", sub("start_", "", start_names_ordered)))
  colnames(window_pairs) <- c("start", "end")

  # Parse start/end columns to identify window names.
  parse_window_columns <- function(start_cols, end_cols) {
    cols_dt <- data.table::data.table(start_col = start_cols)
    cols_dt[, window_name := sub("^start_", "", start_col)]
    cols_dt[, end_col := paste0("end_", window_name)]
    cols_dt <- cols_dt[end_col %in% end_cols]
    return(cols_dt[])
  }

  # Normalize priority metadata into long format:
  # dose_n_window, dose_n_plus_1_window, priority
  normalize_windows_priority <- function(x) {
    if (is.null(x)) {
      return(NULL)
    }

    if (!data.table::is.data.table(x)) x <- data.table::as.data.table(x)

    required_long <- c("dose_n_window", "dose_n_plus_1_window", "priority")
    if (all(required_long %in% names(x))) {
      x <- x[, required_long, with = FALSE]
      x[, dose_n_window := as.character(dose_n_window)]
      x[, dose_n_plus_1_window := as.character(dose_n_plus_1_window)]
      x[, priority := toupper(trimws(priority))]
      return(x[x[["priority"]] %in% c("A", "B")])
    }

    # MxM input case: one row-axis column + many dose_n_plus_1 window columns.
    id_col <- names(x)[grep("dose_n_window", names(x), fixed = TRUE)][1]
    if (is.na(id_col)) {
      stop("Could not identify Dose N window axis in windows_priority metadata.")
    }

    long_x <- data.table::melt(
      x,
      id.vars = id_col,
      variable.name = "dose_n_plus_1_window",
      value.name = "priority"
    )
    data.table::setnames(long_x, id_col, "dose_n_window")
    long_x[, dose_n_window := as.character(dose_n_window)]
    long_x[, dose_n_plus_1_window := as.character(dose_n_plus_1_window)]
    long_x[, priority := toupper(trimws(priority))]
    long_x <- long_x[long_x[["priority"]] %in% c("A", "B")]
    return(long_x[, c("dose_n_window", "dose_n_plus_1_window", "priority"), with = FALSE])
  }

  read_windows_priority <- function(priority_obj) {
    if (!is.null(priority_obj)) {
      return(normalize_windows_priority(priority_obj))
    }

    data("WindowPriority")

    print("Generic configuration file was loaded")
    return(normalize_windows_priority(WindowPriority))
  }

  check_priority_compatibility <- function(priority_long, parsed_cols, using_generic_config) {
    if (is.null(priority_long) || nrow(priority_long) == 0) {
      return(invisible(NULL))
    }

    object_windows <- sort(unique(parsed_cols$window_name))
    priority_windows <- sort(unique(c(priority_long$dose_n_window, priority_long$dose_n_plus_1_window)))

    same_windows <- length(object_windows) == length(priority_windows) &&
      all(object_windows == priority_windows)

    if (same_windows) {
      return(invisible(NULL))
    }

    missing_in_priority <- setdiff(object_windows, priority_windows)
    extra_in_priority <- setdiff(priority_windows, object_windows)

    details <- paste0(
      if (length(missing_in_priority) > 0) {
        paste0(" Missing in windows_priority: ", paste(missing_in_priority, collapse = ", "))
      } else {
        ""
      },
      if (length(extra_in_priority) > 0) {
        paste0(" Extra in windows_priority: ", paste(extra_in_priority, collapse = ", "))
      } else {
        ""
      }
    )

    if (using_generic_config) {
      stop(
        paste0(
          "Generic WindowPriority configuration is not compatible with windows in sp_windows_object.",
          details,
          " Please provide a compatible windows_priority input."
        )
      )
    }

    stop(
      paste0(
        "windows_priority is not compatible with windows in sp_windows_object.",
        details
      )
    )
  }

  apply_overlap_priority_rules <- function(data, priority_long, parsed_cols) {
    if (is.null(priority_long) || nrow(priority_long) == 0) {
      return(invisible(NULL))
    }

    # Apply overlap rules between consecutive doses (N and N+1), ordered by t0_date.
    dose_order_col <- names(data)[tolower(names(data)) == "t0_date"][1]
    if (is.na(dose_order_col)) {
      if (nrow(data) > 1) {
        stop("sp_windows_object must contain t0_date to apply overlap priority rules across doses")
      }
      return(invisible(NULL))
    }

    group_cols <- intersect(c("id"), names(data))
    if (length(group_cols) > 0) {
      group_rows <- data[, .(rows = list(.I)), by = group_cols]$rows
    } else {
      group_rows <- list(seq_len(nrow(data)))
    }

    for (rows in group_rows) {
      if (length(rows) < 2) {
        next
      }

      ordered_rows <- rows[order(data[[dose_order_col]][rows], na.last = TRUE)]
      if (length(ordered_rows) < 2) {
        next
      }

      for (n in seq_len(length(ordered_rows) - 1)) {
        idx_n <- ordered_rows[n]
        idx_np1 <- ordered_rows[n + 1]

        for (i in seq_len(nrow(parsed_cols))) {
          for (j in seq_len(nrow(parsed_cols))) {
            w1 <- parsed_cols$window_name[i]
            w2 <- parsed_cols$window_name[j]
            col1_start <- parsed_cols$start_col[i]
            col1_end <- parsed_cols$end_col[i]
            col2_start <- parsed_cols$start_col[j]
            col2_end <- parsed_cols$end_col[j]

            rule <- priority_long[
              dose_n_window == w1 & dose_n_plus_1_window == w2,
              priority
            ]
            if (length(rule) == 0 || is.na(rule[1])) next
            rule <- rule[1]

            start_n <- data[[col1_start]][idx_n]
            end_n <- data[[col1_end]][idx_n]
            start_np1 <- data[[col2_start]][idx_np1]
            end_np1 <- data[[col2_end]][idx_np1]

            if (is.na(start_n) || is.na(end_n) || is.na(start_np1) || is.na(end_np1)) {
              next
            }

            is_overlap <- (start_n <= end_np1) && (start_np1 <= end_n)
            if (!is_overlap) {
              next
            }

            if (identical(rule, "B")) {
              new_end_n <- min(end_n, start_np1 - 1)
              data[idx_n, (col1_end) := new_end_n]
            }
            if (identical(rule, "A")) {
              new_start_np1 <- max(start_np1, end_n + 1)
              data[idx_np1, (col2_start) := new_start_np1]
            }
          }
        }
      }
    }

    invisible(NULL)
  }

  parsed_cols <- parse_window_columns(start_names, end_names)
  using_generic_config <- is.null(windows_priority)
  priority_long <- read_windows_priority(windows_priority)
  check_priority_compatibility(priority_long, parsed_cols, using_generic_config)
  apply_overlap_priority_rules(data = sp_windows_object, priority_long = priority_long, parsed_cols = parsed_cols)


  if (length(censoring_dates) == 1) {
    sp_windows_object[, int_censdate := censoring_dates]
  } else {
    # first extract any censoring dates
    # get minimum date per row and handle NAs
    min_date_ignore_na <- function(.SD) {
      non_na_dates <- na.omit(as.vector(unlist(.SD)))
      if (length(non_na_dates) == 0) {
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
    start_col <- window_pairs[i, "start"]
    end_col <- window_pairs[i, "end"]

    # Update 'end' column value if event between start and end to date of censoring event
    sp_windows_object[
      int_censdate >= get(start_col) & int_censdate < get(end_col),
      (end_col) := int_censdate
    ]

    # set start and end to NA if the censoring event happens before the start window (by necessity then also before the end)
    sp_windows_object[
      int_censdate < get(start_col),
      c(start_col, end_col) := NA
    ]

    #
  }

  # remove internal censoring date column
  sp_windows_object[, int_censdate := NULL]


  # 3. Chek if end_{window}_{n} < start_{window}_{n}; if so, set both both dates to NA.


  return(sp_windows_object)
}
