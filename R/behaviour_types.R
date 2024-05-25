#' @title Qualtrics behaviour types
#'
#' @description Broad categories to which observed behaviours are assigned.
#'
#' @note Construction of the data is documented in helper_behaviour_types.R. 
#' @note Spelling and grammatical errors are reflected in source Qualitrics
#' survey data and not corrected.
#' @note The categories presented differ from the categories detailed in the
#' Qualtrics survey data. For example, the category titled `Inappropriate
#' Behaviors` is recorded as a mix of `Self-Regulation` and `Antisocial` in Q3
#' of the Qualtrics survey. 
#'
#'
#' @format A tibble with 22 rows and 3 variables:
#' \describe{
#'   \item{type}{behaviour type}
#'   \item{behaviour}{observed behaviour}
#'   \item{color}{color for graphics}
#' }
#' @source Anne Kupfer personal communication
"behaviour_types"
