source("../../R/identify_start_end_cols.R")
source("../../R/wrangle_window.R")

test_that("wrangle_window requires windows_priority when generic config is incompatible", {
  library(data.table)

  sp_obj <- data.table(
    id = c("1", "1"),
    outcome = c("event1", "event1"),
    t0 = c("FIRST_TARGET", "SECOND_TARGET"),
    t0_date = c(as.Date("2021-01-01"), as.Date("2021-02-01")),
    start_risk = as.Date(c("2021-01-01", "2021-02-01")),
    end_risk = as.Date(c("2021-01-20", "2021-02-20")),
    start_control = as.Date(c("2020-12-15", "2021-01-15")),
    end_control = as.Date(c("2020-12-31", "2021-01-31")),
    death_date = as.Date(c(NA, NA)),
    general_end_fup = as.Date(c("2021-12-31", "2021-12-31"))
  )

  expect_error(
    wrangle_window(
      sp_windows_object = copy(sp_obj),
      censoring_dates = c("death_date", "general_end_fup"),
      windows_priority = NULL
    ),
    "Please provide a compatible windows_priority input"
  )
})

test_that("wrangle_window applies custom compatible windows_priority", {
  library(data.table)

  sp_obj <- data.table(
    id = c("1", "1"),
    outcome = c("event1", "event1"),
    t0 = c("FIRST_TARGET", "SECOND_TARGET"),
    t0_date = as.Date(c("2021-01-01", "2021-02-01")),
    start_risk = as.Date(c("2021-01-01", "2021-02-01")),
    end_risk = as.Date(c("2021-01-20", "2021-02-20")),
    start_control = as.Date(c("2020-12-15", "2021-01-10")),
    end_control = as.Date(c("2020-12-31", "2021-01-30")),
    death_date = as.Date(c(NA, NA)),
    general_end_fup = as.Date(c("2021-12-31", "2021-12-31"))
  )

  priority_long <- data.table(
    outcome = "event1",
    dose_n_window = c("risk", "control", "risk", "control"),
    dose_n_plus_1_window = c("risk", "control", "control", "risk"),
    priority = c("B", "B", "B", "B")
  )

  out <- wrangle_window(
    sp_windows_object = copy(sp_obj),
    censoring_dates = c("death_date", "general_end_fup"),
    windows_priority = priority_long
  )

  # B means Dose N+1 window prevails when overlapping Dose N.
  expect_equal(out$end_risk[1], as.Date("2021-01-09"))
  expect_equal(out$start_control[2], as.Date("2021-01-10"))
})

test_that("wrangle_window applies overlap rules for N and N+1 over 3 doses", {
  library(data.table)

  sp_obj <- data.table(
    id = c("1", "1", "1"),
    outcome = c("event1", "event1", "event1"),
    t0 = c("FIRST_TARGET", "SECOND_TARGET", "THIRD_TARGET"),
    t0_date = as.Date(c("2021-01-01", "2021-02-01", "2021-03-01")),
    start_risk = as.Date(c("2021-01-01", "2021-02-01", "2021-03-01")),
    end_risk = as.Date(c("2021-01-20", "2021-02-20", "2021-03-20")),
    start_control = as.Date(c("2020-12-15", "2021-01-10", "2021-02-10")),
    end_control = as.Date(c("2020-12-31", "2021-01-30", "2021-02-28")),
    death_date = as.Date(c(NA, NA, NA)),
    general_end_fup = as.Date(c("2021-02-25", "2021-02-25", "2021-02-25"))
  )

  priority_long <- data.table(
    outcome = "event1",
    dose_n_window = c("risk", "control", "risk", "control"),
    dose_n_plus_1_window = c("risk", "control", "control", "risk"),
    priority = c("B", "B", "B", "B")
  )

  out <- wrangle_window(
    sp_windows_object = copy(sp_obj),
    censoring_dates = c("death_date", "general_end_fup"),
    windows_priority = priority_long
  )

  # First iteration (N=1 vs N+1=2)
  expect_equal(out$end_risk[1], as.Date("2021-01-09"))
  # Second iteration (N=2 vs N+1=3)
  expect_equal(out$end_risk[2], as.Date("2021-02-09"))
  # Censoring by general_end_fup
  expect_equal(out$end_risk[3], as.Date(NA)) #Should be NA because both start and end are after the general_end_fup
  expect_equal(out$start_risk[3], as.Date(NA))
  expect_equal(out$end_control[3], as.Date("2021-02-25"))
})
