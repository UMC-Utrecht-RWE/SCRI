#' Default Model Configuration for Study Designs
#'
#' A dataset specifying which statistical model should be used by default for each study design type.
#' This allows different self-controlled study designs (SCRI, SCCS, SCAD, CCS) to have different default models.
#'
#' @format A data frame with 4 rows and 2 columns:
#' \describe{
#'   \item{design_name}{Character. Study design identifier (e.g., "scri", "sccs", "scad", "ccs").}
#'   \item{model_name}{Character. The default model for this design. Must exist in \code{\link{valid_models}}.}
#' }
#'
#' @details
#' This dataset is accessed by \code{\link{get_DefaultModels}} when model_name is NULL in \code{\link{validate_model_name}}.
#'
#' Current defaults by design:
#' \itemize{
#'   \item \strong{scri}: Self-Controlled Risk Interval -> log_reg
#' }
#'
#' To change the default model for a design, update the corresponding row and regenerate the data files.
#'
#' @examples
#' data("DefaultModels")
#' print(DefaultModels)
#'
#' @keywords datasets
"DefaultModels"
DefaultModels <- data.frame(
  design_name = c("scri"),
  model_name = c("log_reg"),
  stringsAsFactors = FALSE
)
#' usethis::use_data(DefaultModels, overwrite = TRUE)