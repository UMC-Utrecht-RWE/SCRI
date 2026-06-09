test_that("execute sca", {
  
  expect_true(validate_model_name(model_name = 'log_reg', sca_analysis_name = 'scri'))
  
  expect_true(validate_model_name(model_name = 'lin_reg', sca_analysis_name = 'scri'))
  
  validate_model_name(model_name = NULL, sca_analysis_name = 'scri')
  
  
})