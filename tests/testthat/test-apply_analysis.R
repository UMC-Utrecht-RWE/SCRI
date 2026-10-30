make_analytical <- function() {
  set.seed(4821)
  n <- 30
  dt <- data.table::rbindlist(lapply(seq_len(n), function(i) {
    data.table::data.table(
      id = as.character(i),
      outcome = "myo",
      window_name = c("control", "risk"),
      window_length = c(10, 20),
      length = c(10, 20),
      reference_date_name = "covid_vaccine_1",
      event = c(as.integer(i <= 6 || i > 18 && i <= 24), as.integer(i <= 18)),
      sex = if (i %% 2 == 0) "F" else "M"
    )
  }))
  dt
}

test_that("apply_analysis validates inputs", {
  dt <- make_analytical()

  expect_error(apply_analysis(as.data.frame(dt), "covid_vaccine_1", "control"), "must be a data.table")
  expect_error(
    apply_analysis(dt[, !"outcome"], "covid_vaccine_1", "control"),
    "Missing required column.*outcome"
  )
  expect_error(apply_analysis(dt, 1, "control"), "reference_date_name.*single character")
  expect_error(apply_analysis(dt, c("a", "b"), "control"), "reference_date_name.*single character")
  expect_error(apply_analysis(dt, "other", "control"), "not found in `reference_date_name`")
  expect_error(apply_analysis(dt, "covid_vaccine_1", 1), "reference_window.*single character")
  expect_error(apply_analysis(dt, "covid_vaccine_1", c("a", "b")), "reference_window.*single character")
  expect_error(apply_analysis(dt, "covid_vaccine_1", "nope"), "not found in `window_name`")
  expect_error(apply_analysis(dt, "covid_vaccine_1", "control", strata_column_name = 1), "must be a character")
  expect_error(
    apply_analysis(dt, "covid_vaccine_1", "control", strata_column_name = "zzz"),
    "Invalid strata column name.*zzz"
  )
})

test_that("apply_analysis returns counts, person-time and IRR per outcome", {
  dt <- make_analytical()
  res <- suppressWarnings(apply_analysis(dt, "covid_vaccine_1", "control"))

  expect_s3_class(res, "data.table")
  expect_equal(nrow(res), 1)
  expect_equal(res$outcome, "myo")
  expect_equal(res$n_event_control, 12)
  expect_equal(res$n_event_risk, 18)
  expect_equal(res$time_control, 300)
  expect_equal(res$time_risk, 600)
  # 12 control-only vs 12 risk-only discordant pairs, risk window twice as long: IRR = 1
  expect_equal(res$irr_risk_vs_control, 1, tolerance = 1e-6)
  expect_lt(res$irr_risk_vs_control_lowci, res$irr_risk_vs_control)
  expect_gt(res$irr_risk_vs_control_upci, res$irr_risk_vs_control)
  expect_true(all(c("irr_risk_vs_control_lowci", "irr_risk_vs_control_upci") %in% names(res)))
})

test_that("apply_analysis returns one row per outcome", {
  dt <- make_analytical()
  dt2 <- data.table::copy(dt)[, outcome := "event2"]
  dt2[, event := rev(event)]
  full <- data.table::rbindlist(list(dt, dt2))

  res <- suppressWarnings(apply_analysis(full, "covid_vaccine_1", "control"))
  expect_equal(sort(res$outcome), c("event2", "myo"))
})

test_that("apply_analysis runs with a strata column", {
  dt <- make_analytical()
  res <- suppressWarnings(apply_analysis(dt, "covid_vaccine_1", "control", strata_column_name = "sex"))
  expect_s3_class(res, "data.table")
  expect_equal(nrow(res), 1)
  expect_true("irr_risk_vs_control" %in% names(res))
})

test_that("apply_analysis runs once per strata column", {
  dt <- make_analytical()
  dt[, grp := rep(c("a", "b", "c"), length.out = .N)]
  res <- suppressWarnings(apply_analysis(dt, "covid_vaccine_1", "control", strata_column_name = c("sex", "grp")))
  expect_equal(nrow(res), 2)
})

test_that("apply_analysis returns -88 when the reference window has no events", {
  dt <- make_analytical()
  dt[window_name == "control", event := 0L]
  expect_output(
    res <- suppressWarnings(apply_analysis(dt, "covid_vaccine_1", "control")),
    "No events"
  )
  expect_equal(res$irr_risk_vs_control, -88)
  expect_equal(res$irr_risk_vs_control_lowci, -88)
  expect_equal(res$irr_risk_vs_control_upci, -88)
})

test_that("apply_analysis computes IRRs relative to a non-alphabetically-first reference", {
  # 12 individuals with control-only events, 6 with risk-only; equal window lengths
  dt <- data.table::rbindlist(lapply(1:30, function(i) {
    data.table::data.table(
      id = as.character(i),
      outcome = "myo",
      window_name = c("control", "risk"),
      window_length = c(10, 10),
      length = c(10, 10),
      reference_date_name = "covid_vaccine_1",
      event = c(as.integer(i <= 12), as.integer(i > 12 && i <= 18))
    )
  }))

  vs_control <- suppressWarnings(apply_analysis(data.table::copy(dt), "covid_vaccine_1", "control"))
  vs_risk <- suppressWarnings(apply_analysis(data.table::copy(dt), "covid_vaccine_1", "risk"))

  expect_equal(vs_control$irr_risk_vs_control, 0.5, tolerance = 1e-6)
  expect_equal(vs_risk$irr_control_vs_risk, 2, tolerance = 1e-6)
})
