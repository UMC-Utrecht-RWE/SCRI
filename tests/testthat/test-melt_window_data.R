

test_that("melt_window_data returns a data table, correct number of rows and correct column names", {
  wide_file_windows_trimmed <- data.table::data.table(
    id = 1:3,
    outcome = c('event1','event2','event1'),
    start_window1 = c("2021-01-01", "2021-02-01", "2021-03-01"),
    end_window1 = c("2021-01-31", "2021-02-28", "2021-03-31"),
    start_window2 = c("2021-04-01", "2021-05-01", "2021-06-01"),
    end_window2 = c("2021-04-30", "2021-05-31", "2021-06-30")
  )

  # Create a mock wide_file_windows_trimmed data frames
  result <- melt_window_data(wide_file_windows_trimmed)

  # Check that the result is a data frame
  expect_contains(class(result), "data.table")
  expect_equal(nrow(result), nrow(wide_file_windows_trimmed) * 2)
  # Check that the result has the correct column names
  expect_equal(names(result), c("id","outcome" , "window_name", "start", "end"))
})

test_that("melt_window_data handles NA values correctly", {
  # Create a mock wide_file_windows_trimmed data frame with NA values
  wide_file_windows_trimmed <- data.table::data.table(
    id = 1:3,
    outcome = c('event1','event2','event1'),
    start_window1 = c("2021-01-01", NA, "2021-03-01"),
    end_window1 = c("2021-01-31", "2021-02-28", "2021-03-31"),
    start_window2 = c("2021-04-01", "2021-05-01", "2021-06-01"),
    end_window2 = c("2021-04-30", "2021-05-31", "2021-06-30")
  )

  result <- melt_window_data(wide_file_windows_trimmed)

  # Check that the result handles NA values correctly
  expect_true(any(is.na(result$start)))
})

test_that("melt_window_data handles non-default prefixes correctly", {
  # Create a mock wide_file_windows_trimmed data frame with non-default prefixes
  wide_file_windows_trimmed <- data.table::data.table(
    id = 1:3,
    outcome = c('event1','event2','event1'),
    begin_window1 = c("2021-01-01", "2021-02-01", "2021-03-01"),
    finish_window1 = c("2021-01-31", "2021-02-28", "2021-03-31"),
    begin_window2 = c("2021-04-01", "2021-05-01", "2021-06-01"),
    finish_window2 = c("2021-04-30", "2021-05-31", "2021-06-30")
  )

  result <- melt_window_data(wide_file_windows_trimmed, start_column_prefix = "begin", end_column_prefix = "finish")

  # Check that the result handles non-default prefixes correctly
  expect_equal(names(result), c("id", "outcome" ,"window_name", "begin", "finish"))
})

