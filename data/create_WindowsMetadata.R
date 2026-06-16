# # Load required library
# library(data.table)
# 
# # Create WindowsMetadata data.table
# create_windows_metadata <- function() {
#   # Define the data
#   windows_data <- data.table(
#     outcome = rep("event1", 4),
#     window_name = c(
#       "control",
#       "induction",
#       "risk",
#       "washout"
#     ),
#     start_window = c(-365, 1, 43, 74),
#     length_window = c(365, 42, 30, 60)
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
