test_that("select dates from window returns the corrects outptut", {
  records_table <- data.table::data.table(
    person_id = c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5),
    date = as.Date(c('2023-01-01', '2023-01-05', '2023-01-15', '2023-01-25',
                     '2023-02-01', '2023-02-10', '2023-02-25', '2023-03-01',
                     '2023-03-01', '2023-03-05', '2023-03-15', '2023-03-25',
                     '2023-03-26', '2023-03-30', '2023-04-01', '2023-04-10',
                     '2023-01-01', '2023-01-15', '2023-02-01', '2023-02-15')),
    value = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200)
  )

  scri_trimmed <- data.table::data.table(
    person_id = c(1, 1, 2, 2, 3, 4),
    window_name = c('control', 'risk', 'control', 'risk', 'control', 'risk'),
    start_date = as.Date(c('2023-01-01', '2023-01-11', '2023-02-01', '2023-02-21', '2023-03-01', '2023-03-25')),
    end_date = as.Date(c('2023-01-10', '2023-01-21', '2023-02-20', '2023-03-01', '2023-03-10', '2023-04-05'))
  )

  variable_name <- 'EXAMPLE1'
  window_name <- 'risk'
  result_test_risk <- get_records(variable_name,
                                          window_name,
                                          records_table, # record table of interest, minimum expected columns are: person_id, date, value
                                          scri_trimmed,
                                          start_window_date_col_name = 'start_date', # column name
                                          end_window_date_col_name = 'end_date', # column name
                                          only_first_date = FALSE,
                                          wide_format_input = FALSE)
  expected_risk <- data.table::data.table(
    person_id = c(1, 2,2, 4, 4, 4),
    variable = "EXAMPLE1",
    WindowName = "risk",
    WindowLength = c(10, 8, 8,11, 11, 11),
    Date = as.Date(c('2023-01-15', '2023-02-25','2023-03-01','2023-03-26', '2023-03-30', '2023-04-01')),
    START_DATE = as.Date(c('2023-01-11', '2023-02-21','2023-02-21',  '2023-03-25', '2023-03-25', '2023-03-25')),
    END_DATE = as.Date(c('2023-01-21', '2023-03-01','2023-03-01', '2023-04-05', '2023-04-05', '2023-04-05'))
  )

  expect_equal(result_test_risk, expected_risk)

  variable_name <- 'EXAMPLE2'
  window_name <- 'control'
  result_test_control <- get_records(variable_name,
                                             window_name,
                                             records_table, # record table of interest, minimum expected columns are: person_id, date, value
                                             scri_trimmed,
                                             start_window_date_col_name = 'start_date', # column name
                                             end_window_date_col_name = 'end_date', # column name
                                             only_first_date = TRUE,
                                             wide_format_input = FALSE)
  expected_control <- data.table::data.table(
    person_id = c(1, 2, 3),
    variable = "EXAMPLE2",
    WindowName = "control",
    WindowLength = c(9, 19, 9),
    Date = as.Date(c('2023-01-01', '2023-02-01', '2023-03-01')),
    START_DATE = as.Date(c('2023-01-01', '2023-02-01', '2023-03-01')),
    END_DATE = as.Date(c('2023-01-10', '2023-02-20', '2023-03-10'))
  )
  expect_equal(result_test_control, expected_control)

})
