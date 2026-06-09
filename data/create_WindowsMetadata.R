# # Load required library
# library(data.table)
# 
# # Create WindowsMetadata data.table
# create_windows_metadata <- function() {
#   # Define the data
#   windows_data <- data.table(
#     outcome = rep("event1", 10),
#     window_name = c(
#       "washout_pre",
#       "control_pre",
#       "clean_lookback_pre",
#       "risk_pre",
#       "clean_lookback_post",
#       "risk_post",
#       "washout_post",
#       "control_post",
#       "induction_pre",
#       "induction_post"
#     ),
#     start_window = c(-30, -90, -455, 1, -365, 1, 43, 73, 0, 0),
#     length_window = c(30, 60, 365, 42, 365, 42, 30, 60, 1, 1)
#   )
#   
#   # Return the data.table
#   return(windows_data)
# }
# 
# # Execute the function and assign the result to WindowsMetadata
# WindowsMetadata <- create_windows_metadata()
# 
# # Print the result to verify
# print(WindowsMetadata)
# 
# # Save the data to an RData file
# usethis::use_data(WindowsMetadata, overwrite = TRUE)
# 
# # To verify the saved data
# # load("WindowsMetadata.RData")
# # print(WindowsMetadata)