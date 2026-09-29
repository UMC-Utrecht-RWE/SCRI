test_that("construct_window returns expected object type and dose-row shape", {
  library(data.table)
  studypop <- data.table(
    id = as.character(c(1, 2)),
    FIRST_VAC = as.Date(c("2021-01-05", "2023-04-05")),
    SECOND_VAC = as.Date(c("2022-01-05", "2024-04-05")),
    TESTCOL = c(TRUE, FALSE)
  )
  # meta data with only one vaccine/window type
  meta <- data.table(
    outcome = c("outcome1", "outcome1", "pericarditis", "pericarditis"),
    window_name = c("control", "risk", "control", "risk"),
    start_window = c(0, 15, 0, 15),
    length_window = c(10, 20, 10, 20)
  )
  # apply function with different combinations of output options and input metadata
  testout_wide <- construct_window(studypop, meta, id_column = "id", reference_date_name = "FIRST_VAC")
  testout_wide2 <- construct_window(studypop, meta, id_column = "id", reference_date_name = c("FIRST_VAC", "SECOND_VAC"))


  # retain all input rows
  # output now has one row per reference date and outcome
  expect_equal(nrow(studypop) * length(unique(meta$outcome)) * 1, nrow(testout_wide))
  expect_equal(nrow(studypop) * length(unique(meta$outcome)) * 2, nrow(testout_wide2))

  # expect a start and end column for each window type
  expect_true(all(paste0("start_", unique(meta$window_name)) %in% colnames(testout_wide)))
  expect_true(all(paste0("end_", unique(meta$window_name)) %in% colnames(testout_wide)))
  expect_true(all(paste0("start_", unique(meta$window_name)) %in% colnames(testout_wide2)))
  expect_true(all(paste0("end_", unique(meta$window_name)) %in% colnames(testout_wide2)))

  # expect that the windows are given as class Date
  expect_s3_class(testout_wide$start_control, "Date")
  expect_true("t0_date" %in% colnames(testout_wide))

  # retain input columns except reference_date_name columns
  expected_input_cols <- setdiff(colnames(studypop), c("FIRST_VAC", "SECOND_VAC"))
  expect_true(all(expected_input_cols %in% colnames(testout_wide)))
})
