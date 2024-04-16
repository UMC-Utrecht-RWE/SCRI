test_that("compute_windows returns expected object type and shape",{
  studypop <- data.frame(person_id = c(1,2),
                         FIRST_VAC = c("2021-01-05","2023-04-05"),
                         SECOND_VAC = c("2022-01-05","2024-04-05"),
                         TESTCOL = c(TRUE,FALSE))
  # meta data with only one vaccine/window type
  meta <- data.frame(window_name = c("control", "risk"),
                     reference_date = c("FIRST_VAC", "FIRST_VAC"),
                     start_window = c(0,15),
                     length_window = c(10,20))
  # meta data with two distinct reference dates
  meta2 <- data.frame(window_name = c("control_d1", "risk_d1","control_d2","risk_d2"),
                     reference_date = c("FIRST_VAC", "SECOND_VAC"),
                     start_window = c(0,15),
                     length_window = c(10,20))
  # apply function with different combinations of output options and input metadata
  testout_wide <- compute_windows(studypop, meta, id_column = "person_id", output_format = "wide")
  testout_wide2 <- compute_windows(studypop, meta2, id_column = "person_id", output_format = "wide")
  testout_long <- compute_windows(studypop, meta, id_column = "person_id", output_format = "long")
  testout_long2 <- compute_windows(studypop, meta2, id_column = "person_id", output_format = "long")

  # retain all input rows
    # wide version have same number of rows
  expect_equal(nrow(studypop), nrow(testout_wide))
  expect_equal(nrow(studypop), nrow(testout_wide2))
    # long version has windows * person_id number of rows
  expect_equal(length(unique(studypop$person_id)) * nrow(meta), nrow(testout_long))
  expect_equal(length(unique(studypop$person_id)) * nrow(meta2), nrow(testout_long2))

  # expect a start and end column for each window type
  expect_true(all(paste0("start_",unique(meta$window_name)) %in% colnames(testout_wide)))
  expect_true(all(paste0("end_",unique(meta$window_name)) %in% colnames(testout_wide)))
  expect_true(all(paste0("start_",unique(meta2$window_name)) %in% colnames(testout_wide2)))
  expect_true(all(paste0("end_",unique(meta2$window_name)) %in% colnames(testout_wide2)))

  # expect that the windows are given as class Date
  expect_s3_class(testout_wide$start_control, "Date")
  expect_s3_class(testout_long$start, "Date")
  expect_s3_class(testout_long$reference_date, "Date")

  # retain input columns
  expect_true(all(colnames(studypop) %in% colnames(testout_wide)))
  # long version should drop first_vac and write it to reference, retain other columns, add reference_date
  expect_true(all(c("person_id","TESTCOL","reference_date") %in% colnames(testout_long)))
  expect_true(all(unique(meta$reference_date) %in% unique(testout_long$reference)))

  })
