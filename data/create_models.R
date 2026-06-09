# # Define a data frame with valid study designs
# valid_models <- data.frame(
#   model_name = c("log_reg", "lin_reg"),
#   description = c(
#     "Logistic regression: used for modeling binary outcome variables.",
#     "Linear regression: used for modeling continuous outcome variables."
#   ),
#   stringsAsFactors = FALSE
# )
# 
# 
# # Save it as an internal package dataset
# usethis::use_data(valid_models, overwrite = TRUE)
# 
# # Define a data frame with valid study designs
# default_models <- data.frame(
#   design_name = c("cco", "ctc", "scss", "scri"),
#   model_name = c("log_reg", "lin_reg","log_reg","log_reg"),
#   stringsAsFactors = FALSE
# )
# 
# # Save it as an internal package dataset
# usethis::use_data(default_models, overwrite = TRUE)
# 
