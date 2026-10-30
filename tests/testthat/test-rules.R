make_window <- function(start, end) {
  list(start_date = as.Date(start), end_date = as.Date(end))
}

test_that("check_no_overlap returns TRUE for disjoint windows", {
  windows <- list(
    make_window("2021-01-01", "2021-01-10"),
    make_window("2021-01-11", "2021-01-20")
  )
  expect_output(res <- check_no_overlap(windows), "No overlap detected")
  expect_true(res)
})

test_that("check_no_overlap handles empty and single-window lists", {
  expect_true(suppressMessages(capture.output(r <- check_no_overlap(list()))) |> length() >= 0)
  expect_true(r)
  expect_output(expect_true(check_no_overlap(list(make_window("2021-01-01", "2021-01-10")))))
})

test_that("check_no_overlap errors on overlapping windows", {
  windows <- list(
    make_window("2021-01-01", "2021-01-10"),
    make_window("2021-01-05", "2021-01-20")
  )
  expect_output(
    expect_error(check_no_overlap(windows), "Windows cannot overlap"),
    "Overlap detected"
  )
})

test_that("check_no_overlap treats shared boundary day as overlap", {
  windows <- list(
    make_window("2021-01-01", "2021-01-10"),
    make_window("2021-01-10", "2021-01-20")
  )
  expect_output(expect_error(check_no_overlap(windows), "cannot overlap"))
})

test_that("check_no_overlap detects a fully contained window", {
  windows <- list(
    make_window("2021-01-01", "2021-02-01"),
    make_window("2021-01-10", "2021-01-12")
  )
  expect_output(expect_error(check_no_overlap(windows), "cannot overlap"))
})

test_that("check_start_before_end returns TRUE for valid windows", {
  windows <- list(
    make_window("2021-01-01", "2021-01-10"),
    make_window("2021-01-11", "2021-01-11")
  )
  expect_output(res <- check_start_before_end(windows), "All start dates are valid")
  expect_true(res)
})

test_that("check_start_before_end errors when a start is after its end", {
  windows <- list(
    make_window("2021-01-01", "2021-01-10"),
    make_window("2021-02-01", "2021-01-11")
  )
  expect_output(
    expect_error(check_start_before_end(windows), "start dates must be before or equal"),
    "Start date after end date"
  )
})

test_that("add_rule returns the appended rule list", {
  had_registry <- exists("rule_registry", envir = globalenv())
  old <- if (had_registry) get("rule_registry", envir = globalenv())
  assign("rule_registry", list(), envir = globalenv())
  on.exit(
    if (had_registry) assign("rule_registry", old, envir = globalenv()) else rm("rule_registry", envir = globalenv()),
    add = TRUE
  )

  res <- add_rule("scri", check_no_overlap)
  expect_length(res, 1)
  expect_identical(res[[1]], check_no_overlap)
})
