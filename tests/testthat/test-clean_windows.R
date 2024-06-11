test_that("clean_windows retruns expected shape",{
  sp_obj_df <- data.frame(person_id = c(1,2),
                       start_control = c("2021-02-10","2021-03-12"),
                       end_control = c("2021-03-25","2021-04-22"),
                       start_risk = c("2021-04-25","2021-05-23"),
                       end_risk = c("2021-06-23","2021-07-21"),
                       death_date = c(NA,"2025-05-23"),
                       general_end_date = c("2021-05-07","2021-04-14"))

  # apply function with different combinations of output options and input metadata
  expect_message(
    clean_windows(sp_obj_df, censoring_dates = c("general_end_date","death_date")),
    "recoding input object to data.table, please check function documentation"
  )

  sp_obj <- data.table::as.data.table(sp_obj_df)
  testout1 <- suppressMessages(clean_windows(sp_obj,
                                             censoring_dates = c("general_end_date","death_date")
  )
  )
  datecols <- c("start_control","end_control","start_risk","end_risk")

  # test basic output properties
  expect_equal(nrow(testout1), nrow(sp_obj))
  expect_equal(colnames(testout1), colnames(sp_obj))

  # test that all dates after a censoring date are NA
  # manual checking of hard-coded expected output
  # start date after censoring is na
  expect_true(is.na(testout1$start_risk[2]))
  # end date after censoring is na
  expect_true(is.na(testout1$end_risk[2]))
  # end date of first person should end on censoring data
  expect_true(testout1$end_risk[1] == testout1$general_end_date[1])

  # no dates should be present later than the censoring dates
  expect_false(any(testout1[1,..datecols] > testout1[1,general_end_date], na.rm = TRUE))
  expect_false(any(testout1[2,..datecols] > testout1[2,general_end_date], na.rm = TRUE))
  expect_false(any(testout1[1,..datecols] > testout1[1,death_date], na.rm = TRUE))
  expect_false(any(testout1[2,..datecols] > testout1[2,death_date], na.rm = TRUE))



})
