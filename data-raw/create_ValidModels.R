#' Data Creation Script for SCRI Package Models
#'
#' This script creates two internal package datasets:
#'
#' 1. \code{ValidModels}: A registry of all supported statistical models for SCRI analysis
#' 2. \code{DefaultModels}: Configuration specifying which model is the default for each study design
#'
#' These datasets are loaded into the package namespace and accessed by:
#'   - \code{\link{get_ValidModels}}: Returns the registry of available models
#'   - \code{\link{get_DefaultModels}}: Returns the default model for the SCRI design
#'
#' When adding new models to SCRI:
#'   1. Add a row to \code{ValidModels} with model_name and description
#'   2. Add a row to \code{DefaultModels} specifying its design_name (e.g., \"scri\") and model_name
#'   3. Implement the corresponding analysis logic in apply_analysis.R or related files
#'   4. Run \code{usethis::use_data(ValidModels, overwrite = TRUE)} and
#'      \code{usethis::use_data(DefaultModels, overwrite = TRUE)}
#'
#' @keywords internal
NULL

#' Valid Models Registry for SCRI Analysis
#'
#' A dataset containing all statistical models available for use in self-controlled risk interval (SCRI) analysis
#' and related study designs. This registry defines the complete set of supported models and their descriptions.
#'
#' @format A data frame with 2 rows and 2 columns:
#' \describe{
#'   \item{model_name}{Character. Unique identifier for the model (e.g., "log_reg", "lin_reg").}
#'   \item{description}{Character. User-facing description explaining what the model does and when to use it.}
#' }
#'
#' @details
#' This dataset is used by \code{\link{get_ValidModels}} to retrieve available models.
#' When adding new models to SCRI, add a corresponding row to this dataset.
#'
#' The current valid models are:
#' \itemize{
#'   \item \strong{log_reg}: Logistic regression for binary outcomes
#'   \item \strong{lin_reg}: Linear regression for continuous outcomes
#' }
#'
#' @examples
#' data("ValidModels")
#' print(ValidModels)
#'
#' @keywords datasets
"ValidModels"
ValidModels <- data.frame(
  model_name = c("log_reg", "lin_reg"),
  description = c(
    "Logistic regression: used for modeling binary outcome variables.",
    "Linear regression: used for modeling continuous outcome variables."
  ),
  stringsAsFactors = FALSE
)

#' Save datasets to package
#'
#' Uncomment below to regenerate the .rda files after editing:
#' usethis::use_data(ValidModels, overwrite = TRUE)
