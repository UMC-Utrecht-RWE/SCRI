# Test cases for prepare_analytical_dataset function
library(data.table)
library(testthat)

test_that("prepare_analytical_dataset correctly identifies events", {
  # Test data
  test_data <- data.table::data.table(
    id = c(1, 1, 2, 3),
    outcome = c("SCRI", "SCRI", "SCRI", "SCRI"),
    reference_date_name = rep("TARGET1",4),
    window_name = c("W1", "W2", "W1", "W1"),
    window_length = c(30, 30, 30, 30),
    gender = c("M", "F", "M", "M"),
    date = as.Date(c("2023-01-01", "2023-02-15", NA, "2023-03-10"))
  )
  
  # Test without stratification, summing events
  result <- prepare_analytical_dataset(test_data, strata_column_name = NULL, only_first_date = FALSE)
  
  expect_equal(nrow(result), 4)  # One row per id-window combination
  expect_equal(result[id == 1 & window_name == "W1", event], 1)
  expect_equal(result[id == 1 & window_name == "W2", event], 1)
  expect_equal(result[id == 2, event], 0)  # NA date should result in event = 0
  expect_equal(result[id == 3, event], 1)
})

test_that("prepare_analytical_dataset correctly handles only_first_date parameter", {
  # Test data with multiple events for same id-window
  test_data <- data.table::data.table(
    id = c(1, 1, 1, 2),
    reference_date_name = rep("TARGET1",4),
    outcome = c("SCRI", "SCRI", "SCRI", "SCRI"),
    window_name = c("W1", "W1", "W1", "W1"),
    window_length = c(30, 30, 30, 30),
    gender = c("M", "F", "M", "M"),
    date = as.Date(c("2023-01-01", "2023-01-15", "2023-02-20", NA))
  )
  
  # Test with only_first_date = FALSE (sum all events)
  result_sum <- prepare_analytical_dataset(test_data, NULL, FALSE)
  expect_equal(result_sum[id == 1, event], 3)
  
  # Test with only_first_date = TRUE (binary indicator of any event)
  result_first <- prepare_analytical_dataset(test_data, NULL, TRUE)
  expect_equal(result_first[id == 1, event], 1)  # Should be 1 (had events)
  expect_equal(result_first[id == 2, event], 0)  # Should be 0 (no events)
})

test_that("prepare_analytical_dataset correctly applies stratification", {
  # Test data
  test_data <- data.table::data.table(
    id = 1:3,
    reference_date_name = rep("TARGET1",3),
    outcome = rep("SCRI", 3),
    window_name = rep("W1", 3),
    window_length = rep(30, 3),
    gender = c("M", "F", "M"),
    age_group = c("18-45","45-64","65+"),
    date = as.Date(c("2023-01-01", "2023-02-15", NA))
  )
  
  # Test with gender stratification
  result_gender <- prepare_analytical_dataset(test_data, "gender", FALSE)
  
  expect_equal(ncol(result_gender), 7)  # Should include gender column
  expect_true("gender" %in% names(result_gender))
  expect_equal(result_gender[id == 1, gender], "M")
  expect_equal(result_gender[id == 2, gender], "F")
  
  # Test with age_group stratification
  result_age <- prepare_analytical_dataset(test_data, "age_group", FALSE)
  
  expect_true("age_group" %in% names(result_age))
  expect_equal(result_age[id == 1, age_group], "18-45")
  expect_equal(result_age[id == 3, age_group], "65+")
})
