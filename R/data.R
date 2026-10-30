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

#' Default Model Configuration for Study Designs
#'
#' A dataset specifying which statistical model should be used by default for each study design type.
#' This allows different self-controlled study designs (SCRI, SCCS, SCAD, CCS) to have different default models.
#'
#' @format A data frame with 4 rows and 2 columns:
#' \describe{
#'   \item{design_name}{Character. Study design identifier (e.g., "scri", "sccs", "scad", "ccs").}
#'   \item{model_name}{Character. The default model for this design. Must exist in \code{\link{ValidModels}}.}
#' }
#'
#' @details
#' This dataset is accessed by \code{\link{get_DefaultModels}} when model_name is NULL in \code{\link{validate_model_name}}.
#'
#' Current defaults by design:
#' \itemize{
#'   \item \strong{scri}: Self-Controlled Risk Interval -> log_reg
#'   \item \strong{sccs}: Self-Controlled Case Series -> log_reg
#'   \item \strong{scad}: Self-Controlled Age-Dependent -> log_reg
#'   \item \strong{ccs}: Case-Cohort Study -> log_reg
#' }
#'
#' To change the default model for a design, update the corresponding row in data/create_models.R
#' and regenerate the data files with:
#' \code{usethis::use_data(ValidModels, overwrite = TRUE)}
#' \code{usethis::use_data(DefaultModels, overwrite = TRUE)}
#'
#' @examples
#' data("DefaultModels")
#' print(DefaultModels)
#'
#' @keywords datasets
"DefaultModels"
