# source("../R/validation_functions.R")
# source("../R/rename_anchor.R")
# source("../R/construct_windows.R")
# source("../R/identify_start_end_cols.R")
# source("../R/wrangle_window.R")
# source("../R/add_records.R")
# source("../R/prepare_analytical_dataset.R")
# source("../R/stats_functions.R")
# source("../R/apply_analysis.R")
# source("../R/scri.R")

test_that("scri returns analysis table with expected core fields", {
  records_table <- data.table::data.table(
    id = c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5),
    date = as.Date(c(
      "2021-01-01", "2021-01-05", "2021-01-15", "2021-01-25",
      "2023-04-01", "2023-04-10", "2023-04-25", "2023-06-01",
      "2022-02-01", "2022-01-05", "2022-02-15", "2022-03-25",
      "2021-09-26", "2023-10-30", "2023-11-01", "2023-09-10",
      "2023-01-01", "2022-09-15", "2022-10-01", "2023-02-15"
    )),
    value = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200),
    outcome = c("event1", "event1", "event1", "event1", "event1", "event1", "event1", "event1", "event1", "event1", "event1", "event2", "event1", "event1", "event2", "event2", "event1", "event1", "event2", "event2")
  )

  windows_metadata <- data.table::data.table(
    outcome = c("event1", "event1", "event2", "event2"),
    window_name = c("control", "risk", "control", "risk"),
    start_window = c(0, 15, 0, 15),
    length_window = c(10, 20, 10, 20)
  )

  study_population <- data.table::data.table(
    id = as.character(c(1, 2, 3, 4, 5)),
    FIRST_TARGET = as.Date(c("2021-01-05", "2023-04-05", "2022-01-05", "2021-09-05", "2022-09-05")),
    SECOND_TARGET = as.Date(c("2022-01-05", "2024-04-05", NA, NA, NA)),
    op_start_date = as.Date(c("2020-05-07", "2020-05-07", "2020-05-07", "2020-05-07", "2020-05-07")),
    death_date = as.Date(c(NA, "2025-05-23", NA, NA, "2022-09-25")),
    general_end_fup = as.Date(c("2021-05-07", "2021-04-14", "2023-01-01", "2023-01-01", "2022-09-25"))
  )

  windows_priority <- data.table::CJ(
    dose_n_window = c("control", "risk"),
    dose_n_plus_1_window = c("control", "risk")
  )
  windows_priority[, priority := "B"]

  result <- scri(
    study_population = study_population,
    windows_metadata = windows_metadata,
    window_priority = windows_priority,
    records_table = records_table,
    reference_date_name = "FIRST_TARGET",
    reference_window = "control",
    start_followup_criteria = "op_start_date",
    end_followup_criteria = c("death_date", "general_end_fup")
  )

  expect_s3_class(result, "data.table")
  expect_gt(nrow(result), 0)
  expect_true("outcome" %in% names(result))
  expect_equal(sort(unique(result$outcome)), sort(unique(windows_metadata$outcome)))
  expect_true(any(grepl("^n_event_", names(result))))
  expect_true(any(grepl("^time_", names(result))))
  expect_true(any(grepl("^irr_", names(result))))
})

test_that("scri saves all intermediate outputs when save_intermediate is provided", {
  records_table <- data.table::data.table(
    id = c(1, 1, 2, 2),
    date = as.Date(c("2021-01-05", "2021-01-20", "2023-04-10", "2023-04-25")),
    value = c(10, 20, 30, 40),
    outcome = c("event1", "event1", "event1", "event1")
  )

  windows_metadata <- data.table::data.table(
    outcome = c("event1", "event1"),
    window_name = c("control", "risk"),
    start_window = c(0, 15),
    length_window = c(10, 20)
  )

  study_population <- data.table::data.table(
    id = as.character(c(1, 2)),
    FIRST_TARGET = as.Date(c("2021-01-05", "2023-04-05")),
    SECOND_TARGET = as.Date(c("2022-01-05", "2024-04-05")),
    op_start_date = as.Date(c("2020-05-07", "2020-05-07")),
    death_date = as.Date(c(NA, NA)),
    general_end_fup = as.Date(c("2022-12-31", "2024-12-31"))
  )

  windows_priority <- data.table::CJ(
    dose_n_window = c("control", "risk"),
    dose_n_plus_1_window = c("control", "risk")
  )
  windows_priority[, priority := "B"]
  out_dir <- tempfile("scri-test-")
  dir.create(out_dir)

  result <- scri(
    study_population = study_population,
    windows_metadata = windows_metadata,
    window_priority = windows_priority,
    records_table = records_table,
    reference_date_name = "FIRST_TARGET",
    reference_window = "control",
    start_followup_criteria = "op_start_date",
    end_followup_criteria = c("death_date", "general_end_fup"),
    save_intermediate = out_dir
  )

  expect_s3_class(result, "data.table")
  expect_true(file.exists(file.path(out_dir, "scri_computed_windows.csv")))
  expect_true(file.exists(file.path(out_dir, "scri_computed_windows_cleaned.csv")))
  expect_true(file.exists(file.path(out_dir, "scri_indentified_records.csv")))
  expect_true(file.exists(file.path(out_dir, "SCRI_analytical_dataset.csv")))
  expect_true(file.exists(file.path(out_dir, "results_analysis.csv")))
})
