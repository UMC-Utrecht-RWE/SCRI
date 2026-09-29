test_that("execute SCRI model validation", {
  expect_true(validate_model_name(model_name = "log_reg"))

  expect_true(validate_model_name(model_name = "lin_reg"))

  validate_model_name(model_name = NULL)
})
