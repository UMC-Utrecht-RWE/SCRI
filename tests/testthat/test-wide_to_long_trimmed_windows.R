

test_that("wide_to_long_trimmed_windows returns a data table, correct number of rows and correct column names", {
  wide_file_windows_trimmed <- data.table::data.table(
    id = 1:3,
    start_window1 = c("2021-01-01", "2021-02-01", "2021-03-01"),
    end_window1 = c("2021-01-31", "2021-02-28", "2021-03-31"),
    start_window2 = c("2021-04-01", "2021-05-01", "2021-06-01"),
    end_window2 = c("2021-04-30", "2021-05-31", "2021-06-30")
  )

  # Create a mock wide_file_windows_trimmed data frames
  result <- wide_to_long_trimmed_windows(wide_file_windows_trimmed)

  # Check that the result is a data frame
  expect_contains(class(result), "data.table")
  expect_equal(nrow(result), nrow(wide_file_windows_trimmed) * 2)
  # Check that the result has the correct column names
  expect_equal(names(result), c("id", "WindowName", "start", "end"))
})

test_that("wide_to_long_trimmed_windows handles NA values correctly", {
  # Create a mock wide_file_windows_trimmed data frame with NA values
  wide_file_windows_trimmed <- data.table::data.table(
    id = 1:3,
    start_window1 = c("2021-01-01", NA, "2021-03-01"),
    end_window1 = c("2021-01-31", "2021-02-28", "2021-03-31"),
    start_window2 = c("2021-04-01", "2021-05-01", "2021-06-01"),
    end_window2 = c("2021-04-30", "2021-05-31", "2021-06-30")
  )

  result <- wide_to_long_trimmed_windows(wide_file_windows_trimmed)

  # Check that the result handles NA values correctly
  expect_true(any(is.na(result$start)))
})

test_that("wide_to_long_trimmed_windows handles non-default prefixes correctly", {
  # Create a mock wide_file_windows_trimmed data frame with non-default prefixes
  wide_file_windows_trimmed <- data.table::data.table(
    id = 1:3,
    begin_window1 = c("2021-01-01", "2021-02-01", "2021-03-01"),
    finish_window1 = c("2021-01-31", "2021-02-28", "2021-03-31"),
    begin_window2 = c("2021-04-01", "2021-05-01", "2021-06-01"),
    finish_window2 = c("2021-04-30", "2021-05-31", "2021-06-30")
  )

  result <- wide_to_long_trimmed_windows(wide_file_windows_trimmed, start_prefix = "begin", end_prefix = "finish")

  # Check that the result handles non-default prefixes correctly
  expect_equal(names(result), c("id", "WindowName", "begin", "finish"))
})

