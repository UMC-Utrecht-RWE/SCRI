
# Function to check StudyPopulation structure
test_that("StudyPopulation has correct structure", {
  # Check that StudyPopulation exists and is a data frame
  expect_true(exists("StudyPopulation"))
  expect_s3_class(StudyPopulation, "data.table")

  # Expected column names
  reference_date_names <- c("FIRST_TARGET","SECOND_TARGET")
  start_followup_criteria <- 'op_start_date'
  end_followup_criteria <- c('death_date','general_end_fup')
  expected_columns <- c("id", reference_date_names, start_followup_criteria, end_followup_criteria)

  # Check that all expected columns are present
  expect_true(all(expected_columns %in% colnames(StudyPopulation)))

  # Check column types
  expect_type(StudyPopulation$id, "character")
  lapply(reference_date_names,
         function(x) expect_s3_class(StudyPopulation[,get(x)], "Date"))
  lapply(start_followup_criteria,
         function(x) expect_s3_class(StudyPopulation[,get(x)], "Date"))
  lapply(end_followup_criteria,
         function(x) expect_s3_class(StudyPopulation[,get(x)], "Date"))
})
