# Test cases for rename_anchor function
library(data.table)
library(testthat)

test_that("rename_anchor renames a single column correctly", {
  # Setup test data
  test_data <- data.table(
    id = 1:3,
    index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10"))
  )
  
  # Make a copy to verify we're not modifying the original
  original_data <- copy(test_data)
  
  # Test with default prefix
  result <- rename_anchor(test_data, "index_date")
  
  # Verify the column was renamed
  expect_false("index_date" %in% names(result$data))
  expect_true("anch_1" %in% names(result$data))
  
  # Verify the original data is unchanged
  expect_equal(names(original_data), c("id", "index_date"))
  
  # Verify the data content is preserved
  expect_equal(result$data$anch_1, original_data$index_date)
})

test_that("rename_anchor renames multiple columns correctly", {
  # Setup test data with multiple date columns
  test_data <- data.table(
    id = 1:3,
    index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10")),
    cohort_entry = as.Date(c("2022-12-01", "2023-01-01", "2023-02-01")),
    end_date = as.Date(c("2023-06-30", "2023-07-31", "2023-08-31"))
  )
  
  # Test with default prefix for two columns
  result <- rename_anchor(test_data, c("index_date", "cohort_entry"))
  
  # Verify columns were renamed
  expect_false(any(c("index_date", "cohort_entry") %in% names(result$data)))
  expect_true(all(c("anch_1", "anch_2") %in% names(result$data)))
  expect_true("end_date" %in% names(result$data))  # Not renamed
})

test_that("rename_anchor renames multiple columns correctly", {
  test_data <- data.table(
    id = 1:3,
    index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10")),
    cohort_entry = as.Date(c("2022-12-01", "2023-01-01", "2023-02-01")),
    end_date = as.Date(c("2023-06-30", "2023-07-31", "2023-08-31"))
  )
  # Test with custom prefix for all date columns
  result2 <- rename_anchor(test_data, 
                           c("index_date", "cohort_entry", "end_date"), 
                           prefix_name = "ref_")
  
  # Verify all columns were renamed with custom prefix
  expect_false(any(c("index_date", "cohort_entry", "end_date") %in% names(result2$data)))
  expect_true(all(c("ref_1", "ref_2", "ref_3") %in% names(result2$data)))
})

test_that("rename_anchor handles edge cases", {
  # Empty dataframe
  test_empty <- data.table(id = integer(0), ref_date = as.Date(character(0)))
  result_empty <- rename_anchor(test_empty, "ref_date")
  expect_equal(names(result_empty$data), c("id", "anch_1"))
  
  # Empty prefix
  test_data <- data.table(id = 1:3, index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10")))
  result_empty_prefix <- rename_anchor(test_data, "index_date", prefix_name = "")
  expect_equal(names(result_empty_prefix$data), c("id", "1"))
})

test_that("rename_anchor works with data.frame as well as data.table", {
  # Test with data.frame
  test_df <- data.frame(
    id = 1:3,
    index_date = as.Date(c("2023-01-01", "2023-02-15", "2023-03-10"))
  )
  
  result_df <- rename_anchor(test_df, "index_date")
  
  # Verify result is still a data.frame
  expect_s3_class(result_df$data, "data.frame")
  
  # Verify column was renamed
  expect_false("index_date" %in% names(result_df$data))
  expect_true("anch_1" %in% names(result_df$data))
})
