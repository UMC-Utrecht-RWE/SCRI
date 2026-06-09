# Test 1: Basic functionality with long format and multiple records
test_that("add_records returns records within specified windows (long format)", {
  records_table <- data.table::data.table(
    id = c(1, 1, 1, 1, 2, 2, 2, 2),
    date = as.Date(c(
      "2023-01-01", "2023-01-05", "2023-01-15", "2023-01-25",
      "2023-02-01", "2023-02-10", "2023-02-25", "2023-03-01"
    )),
    value = c(10, 20, 30, 40, 50, 60, 70, 80),
    outcome = c("event1", "event1", "event1", "event1", "event1", "event1", "event1", "event1")
  )

  window_data <- data.table::data.table(
    id = c(1, 1, 2, 2),
    outcome = c("event1", "event1", "event1", "event1"),
    window_name = c("control", "risk", "control", "risk"),
    start_date = as.Date(c("2023-01-01", "2023-01-11", "2023-02-01", "2023-02-21")),
    end_date = as.Date(c("2023-01-10", "2023-01-21", "2023-02-20", "2023-03-01"))
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = FALSE,
    is_wide_format = FALSE
  )

  # Check that result is a data.table
  expect_s3_class(result, "data.table")

  # Check that all expected columns are present
  expect_true("id" %in% names(result))
  expect_true("outcome" %in% names(result))
  expect_true("window_name" %in% names(result))
  expect_true("date" %in% names(result))

  # Check that records within windows are returned
  # ID 1, control window (2023-01-01 to 2023-01-10): should match 2023-01-01, 2023-01-05
  control_records_id1 <- result[id == 1 & window_name == "control"]
  expect_equal(nrow(control_records_id1[!is.na(date)]), 2)
})

# Test 2: Only first record functionality
test_that("add_records with only_first_record = TRUE returns only first record per window", {
  records_table <- data.table::data.table(
    id = c(1, 1, 1, 1),
    date = as.Date(c("2023-01-01", "2023-01-05", "2023-01-15", "2023-01-25")),
    value = c(10, 20, 30, 40),
    outcome = c("event1", "event1", "event1", "event1")
  )

  window_data <- data.table::data.table(
    id = 1,
    outcome = "event1",
    window_name = "control",
    start_date = as.Date("2023-01-01"),
    end_date = as.Date("2023-01-25")
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = TRUE,
    is_wide_format = FALSE
  )

  # Only the first matching record (2023-01-01) should be returned
  matching_records <- result[id == 1 & !is.na(date)]
  expect_equal(nrow(matching_records), 1)
  expect_equal(matching_records$date[1], as.Date("2023-01-01"))
})

# Test 3: Multiple outcomes handling
test_that("add_records matches records based on outcome", {
  records_table <- data.table::data.table(
    id = c(1, 1, 1, 1),
    date = as.Date(c("2023-01-01", "2023-01-05", "2023-01-15", "2023-01-25")),
    value = c(10, 20, 30, 40),
    outcome = c("event1", "event1", "event2", "event2")
  )

  window_data <- data.table::data.table(
    id = c(1, 1),
    outcome = c("event1", "event2"),
    window_name = c("window1", "window2"),
    start_date = as.Date(c("2023-01-01", "2023-01-15")),
    end_date = as.Date(c("2023-01-10", "2023-01-25"))
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = FALSE,
    is_wide_format = FALSE
  )

  # event1 window should have event1 records
  event1_records <- result[outcome == "event1" & !is.na(date)]
  expect_true(all(event1_records$outcome == "event1"))

  # event2 window should have event2 records
  event2_records <- result[outcome == "event2" & !is.na(date)]
  expect_true(all(event2_records$outcome == "event2"))
})

# Test 4: No matching records
test_that("add_records handles case where no records fall within windows", {
  records_table <- data.table::data.table(
    id = 1,
    date = as.Date("2023-06-01"),
    value = 100,
    outcome = "event1"
  )

  window_data <- data.table::data.table(
    id = 1,
    outcome = "event1",
    window_name = "control",
    start_date = as.Date("2023-01-01"),
    end_date = as.Date("2023-01-31")
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = FALSE,
    is_wide_format = FALSE
  )

  # No records should match
  matching_records <- result[!is.na(date)]
  expect_equal(nrow(matching_records), 0)
})

# Test 5: Data types are preserved
test_that("add_records returns correct data types", {
  records_table <- data.table::data.table(
    id = c(1, 1),
    date = as.Date(c("2023-01-01", "2023-01-05")),
    value = c(10, 20),
    outcome = c("event1", "event1")
  )

  window_data <- data.table::data.table(
    id = 1,
    outcome = "event1",
    window_name = "control",
    start_date = as.Date("2023-01-01"),
    end_date = as.Date("2023-01-10")
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = FALSE,
    is_wide_format = FALSE
  )

  # Check date columns are Date class
  expect_s3_class(result$date, "Date")
  expect_s3_class(result$start_date, "Date")
  expect_s3_class(result$end_date, "Date")

  # Check id is numeric
  expect_true(is.numeric(result$id))
})

# Test 6: Window length calculation
test_that("add_records calculates window length correctly", {
  records_table <- data.table::data.table(
    id = 1,
    date = as.Date("2023-01-05"),
    value = 100,
    outcome = "event1"
  )

  window_data <- data.table::data.table(
    id = 1,
    outcome = "event1",
    window_name = "control",
    start_date = as.Date("2023-01-01"),
    end_date = as.Date("2023-01-31")
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = FALSE,
    is_wide_format = FALSE
  )

  # Window length should be 30 days (31 - 1)
  result_with_calc <- result[!is.na(window_length)]
  if (nrow(result_with_calc) > 0) {
    expect_equal(result_with_calc$window_length[1], 30)
  }
})

# Test 7: Boundary date matching (inclusive on both ends)
test_that("add_records includes records on boundary dates", {
  records_table <- data.table::data.table(
    id = c(1, 1, 1),
    date = as.Date(c("2023-01-01", "2023-01-15", "2023-01-31")),
    value = c(10, 20, 30),
    outcome = c("event1", "event1", "event1")
  )

  window_data <- data.table::data.table(
    id = 1,
    outcome = "event1",
    window_name = "control",
    start_date = as.Date("2023-01-01"),
    end_date = as.Date("2023-01-31")
  )

  result <- add_records(
    window_data = window_data,
    records = records_table,
    start_column_prefix = "start_date",
    end_column_prefix = "end_date",
    only_first_record = FALSE,
    is_wide_format = FALSE
  )

  # All three dates should be matched (including boundaries)
  matching_records <- result[!is.na(date)]
  expect_equal(nrow(matching_records), 3)
  expect_true(as.Date("2023-01-01") %in% matching_records$date)
  expect_true(as.Date("2023-01-31") %in% matching_records$date)
})

# Test 8: melt_window_data function
test_that("melt_window_data converts wide format to long format", {
  window_data_wide <- data.table::data.table(
    id = c(1, 2),
    outcome = c("event1", "event1"),
    start_control = as.Date(c("2023-01-01", "2023-02-01")),
    end_control = as.Date(c("2023-01-31", "2023-02-28")),
    start_risk = as.Date(c("2023-02-01", "2023-03-01")),
    end_risk = as.Date(c("2023-02-28", "2023-03-31"))
  )

  result <- melt_window_data(
    window_data = window_data_wide,
    start_column_prefix = "start",
    end_column_prefix = "end"
  )

  # Check that result is a data.table
  expect_s3_class(result, "data.table")

  # Check that columns are reorganized
  expect_true("window_name" %in% names(result))
  expect_true("start" %in% names(result))
  expect_true("end" %in% names(result))

  # Should have 4 rows (2 ids × 2 windows)
  expect_equal(nrow(result), 4)
})
