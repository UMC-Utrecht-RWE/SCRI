#' Window Priority Configuration
#'
#' A configuration file specifying overlap-priority rules between consecutive doses for window wrangling.
#' Defines which window takes precedence (A or B) when windows from dose N overlap with windows from dose N+1.
#'
#' @format ## `WindowPriority`
#' A data frame with rows defining priority rules:
#' \describe{
#'   \item{outcome}{Outcome identifier matching those in WindowMetadata (chr)}
#'   \item{dose_n_window}{Window name at dose N (chr)}
#'   \item{dose_n_plus_1_window}{Window name at dose N+1 (chr)}
#'   \item{priority}{Priority rule: "A" = dose N prevails (shifts dose N+1 start forward), "B" = dose N+1 prevails (trims dose N end backward) (chr)}
#' }
#'
#' @details
#' - Priority "A": When windows overlap, dose N window takes precedence. The start of dose N+1 window is shifted to (end of dose N + 1 day).
#' - Priority "B": When windows overlap, dose N+1 window takes precedence. The end of dose N window is trimmed to (start of dose N+1 - 1 day).
#'
#' @seealso [WindowMetadata] for window definitions, [construct_window()] for window computation, [wrangle_window()] for applying priority rules.
"WindowPriority"
