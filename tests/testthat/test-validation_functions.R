make_sp <- function() {
  data.table::data.table(
    id = c("1", "2"),
    covid_vaccine_1 = as.Date(c("2021-01-01", "2021-02-01")),
    extra = as.Date(c("2020-01-01", "2020-02-01")),
    age = c(10, 20),
    grp = c("a", "b")
  )
}

make_wm <- function() {
  data.table::data.table(
    outcome = c("o", "o"),
    window_name = c("control", "risk"),
    start_window = c(0, 15),
    length_window = c(10, 20)
  )
}

# validate_study_population ----
test_that("validate_study_population accepts valid input", {
  expect_no_error(validate_study_population(make_sp(), "covid_vaccine_1"))
  expect_no_error(validate_study_population(make_sp(), "covid_vaccine_1", c("age", "grp"), "extra"))
})

test_that("validate_study_population rejects bad structure", {
  expect_error(validate_study_population(data.frame(id = "1"), "covid_vaccine_1"), "must be a data table")
  expect_error(validate_study_population(make_sp()[, !"id"], "covid_vaccine_1"), "missing required columns: id")
  expect_error(validate_study_population(make_sp(), "nope"), "missing required columns: nope")
  expect_error(validate_study_population(make_sp(), "covid_vaccine_1", extra_date_columns = "nope"), "missing required columns: nope")
})

test_that("validate_study_population checks column types", {
  sp <- make_sp()[, id := 1:2]
  expect_error(validate_study_population(sp, "covid_vaccine_1"), "'id' must be character")

  sp <- make_sp()[, covid_vaccine_1 := as.character(covid_vaccine_1)]
  expect_error(validate_study_population(sp, "covid_vaccine_1"), "Reference date column.*must be Date")

  sp <- make_sp()[, extra := as.character(extra)]
  expect_error(validate_study_population(sp, "covid_vaccine_1", extra_date_columns = "extra"), "must be Date")
})

test_that("validate_study_population checks strata columns", {
  sp <- make_sp()[, grp := as.Date("2020-01-01") + 0:1]
  expect_error(validate_study_population(sp, "covid_vaccine_1", "grp"), "must be numeric or character")

  sp <- make_sp()[, grp := c("a", NA)]
  expect_error(validate_study_population(sp, "covid_vaccine_1", "grp"), "contains missing")
})

# validate_window_metadata ----
test_that("validate_window_metadata accepts valid input and leaves no helper columns", {
  wm <- make_wm()
  res <- validate_window_metadata(wm)
  expect_false(any(c("start", "end") %in% names(res)))
  expect_false(any(c("start", "end") %in% names(wm)))
})

test_that("validate_window_metadata rejects bad structure and types", {
  expect_error(validate_window_metadata(as.data.frame(make_wm())), "must be a data.table")
  expect_error(validate_window_metadata(make_wm()[, !"outcome"]), "missing required columns: outcome")
  expect_error(validate_window_metadata(make_wm()[, outcome := 1:2]), "'outcome' must be character")
  expect_error(validate_window_metadata(make_wm()[, window_name := 1:2]), "'window_name' must be character")
  expect_error(validate_window_metadata(make_wm()[, start_window := c("a", "b")]), "'start_window' must be numeric")
  expect_error(validate_window_metadata(make_wm()[, length_window := c("a", "b")]), "'length_window' must be numeric")
})

test_that("validate_window_metadata warns or errors on overlap", {
  wm <- make_wm()[, start_window := c(0, 5)]
  expect_warning(validate_window_metadata(wm), "Overlapping windows detected")
  expect_error(validate_window_metadata(make_wm()[, start_window := c(0, 5)], error_on_overlap = TRUE), "Overlapping windows detected")
})

test_that("validate_window_metadata flags windows that touch on the boundary day", {
  wm <- make_wm()[, start_window := c(0, 9)]
  expect_warning(validate_window_metadata(wm), "overlapping on: control and risk")
})

test_that("validate_window_metadata only compares windows within the same outcome", {
  wm <- data.table::data.table(
    outcome = c("a", "b"),
    window_name = c("w1", "w2"),
    start_window = c(0, 0),
    length_window = c(10, 10)
  )
  expect_no_warning(validate_window_metadata(wm))
})

# validate_construct_window ----
test_that("validate_construct_window passes with matching start/end columns", {
  sp_windows <- data.table::data.table(
    id = "1", start_control = 1, end_control = 2, start_risk = 3, end_risk = 4
  )
  expect_no_error(validate_construct_window(sp_windows, make_wm()))
})

test_that("validate_construct_window errors when window columns do not match metadata", {
  sp_windows <- data.table::data.table(id = "1", start_other = 1, end_control = 2, end_risk = 3)
  expect_error(validate_construct_window(sp_windows, make_wm()), "not all windows have a start and end")
})

test_that("validate_construct_window errors when only starts or only ends are missing", {
  only_start <- data.table::data.table(id = "1", start_control = 1, end_control = 2, start_risk = 3)
  expect_error(validate_construct_window(only_start, make_wm()), "not all windows have a start and end")
  only_end <- data.table::data.table(id = "1", start_control = 1, end_control = 2, end_risk = 4)
  expect_error(validate_construct_window(only_end, make_wm()), "not all windows have a start and end")
})

# validate_model_name ----
test_that("validate_model_name handles defaults, types and invalid names", {
  expect_message(validate_model_name(NULL), "Model name empty")
  expect_error(validate_model_name(1), "must be character")
  expect_error(validate_model_name("not_a_model"), "Invalid 'model_name'")
})
