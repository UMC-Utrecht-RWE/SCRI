test_that("compute_windows returns expected object type",{
  studypop <- data.frame(person_id = c(1,2),
                         FIRST_VAC = c("2021-01-05","2023-04-05"),
                         TESTCOL = c(TRUE,FALSE))
  meta <- data.frame(window_name = c("control", "risk"),
                     reference_date = c("FIRST_VAC", "FIRST_VAC"),
                     start_window = c(0,15),
                     length_window = c(10,20))
  testout_wide <- compute_windows(studypop, meta, id_column = "person_id", output_format = "wide")
  testout_long <- compute_windows(studypop, meta, id_column = "person_id", output_format = "long")

  # retain all input rows
    # wide version have same number of rows
  expect_equal(nrow(studypop), nrow(testout_wide))
    # long version has windows * person_id number of rows
  expect_equal(length(unique(studypop$person_id)) * nrow(meta), nrow(testout_long))
  # expect a start and end column for each window type
  expect_true(all(paste0("start_",unique(meta$window_name)) %in% colnames(testout_wide)))
  expect_true(all(paste0("end_",unique(meta$window_name)) %in% colnames(testout_wide)))
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
