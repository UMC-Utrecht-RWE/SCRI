#' List Available SCRI Models
#'
#' This function returns a data frame of valid SCRI models along with their descriptions.
#'
#' @return A data frame of available models
#' @export
get_valid_models <- function() {
  # Get the loaded data from the environment
  valid_models <- get("valid_models", envir = environment())

  return(valid_models)
}

#' Get Default SCRI Model
#'
#' This function returns the default model name used in SCRI analysis.
#'
#' @return A character string with the default model name.
#' @keywords internal
#'
get_default_models <- function() {
  # Get the loaded data from the environment
  default_models <- get("default_models", envir = environment())
  default_model <- default_models[default_models$design_name == "scri", "model_name"]
  if (length(default_model) == 0) {
    stop("No default model is configured for SCRI")
  }
  return(default_model)
}
