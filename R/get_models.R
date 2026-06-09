#' List Available Self-Controlled Study Designs
#'
#' This function returns a data frame of valid models along with their descriptions.
#'
#' @return A data frame of available models
#' @export
get_valid_models <- function() {
  # Get the loaded data from the environment
  valid_models <- get("valid_models", envir = environment())

  return(valid_models)
}

#' List Default models
#'
#' This function returns a data frame of the default model for a specific SCRI_tudy_design
#'
#' @return A data frame of available study designs.
#' @keywords internal
#'
get_default_models <- function(SCRI_analysis_name) {
  # Get the loaded data from the environment
  default_models <- get("default_models", envir = environment())
  default_model <- default_models[default_models$design_name == SCRI_analysis_name, "model_name"]
  if (length(default_model) == 0) {
    stop("SCRI_analysis_name has incorrect name")
  }
  return(default_model)
}
