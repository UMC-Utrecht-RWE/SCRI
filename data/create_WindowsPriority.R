# # Load required library
# library(data.table)
# 
# # Create a matrix-like long table for Dose N x Dose N+1 window priority.
# # In this structure, all combinations where Dose N+1 is the first window
# # are marked as "B" to mirror the reference diagram.
# create_windows_priority <- function(
#   window_names = c("control", "induction", "risk", "washout")
# ) {
#   windows_data <- CJ(
#     dose_n_window = window_names,
#     dose_n_plus_1_window = window_names,
#     sorted = FALSE
#   )
# 
#   windows_data[, priority := "B"]
# 
#   return(windows_data[])
# }
# 
# # Convert long format to an MxM two-way table.
# create_windows_priority_mxm <- function(windows_priority_long) {
#   mxm_table <- dcast(
#     windows_priority_long,
#     dose_n_window ~ dose_n_plus_1_window,
#     value.var = "priority"
#   )
# 
#   setnames(mxm_table, "dose_n_window", "dose_n_window/dose_n_plus_1_window")
# 
#   return(mxm_table[])
# }
# 
# load("~/Documents/GitHub/SCRI/data/WindowsMetadata.rda")
# 
# # Execute the function and assign the result to WindowsPriority
# WindowsPriority <- create_windows_priority(window_names = unique(WindowsMetadata$window_name))
# WindowsPriorityMxM <- create_windows_priority_mxm(WindowsPriority)
# 
# # Print the result to verify
# print(WindowsPriority)
# print(WindowsPriorityMxM)
# 
# # Save as RDS and CSV
# saveRDS(WindowsPriorityMxM, file = "../data/WindowsPriority.rds")
