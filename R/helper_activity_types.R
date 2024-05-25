#' @title R code to construct activity_types package data object
#'
#' @description R code to construct the \code{activity_types} data object in
#' the cslqualtrics package; included for reference (not exported).
#'
#' importFrom tibble tribble
#'
#' @examples
#' \dontrun{
#' activity_types <- generate_activity_types()
#' usethis::use_data(activity_types, overwrite = TRUE)
#' }
#'
generate_activity_types <- function() {

  activity_types <- tibble::tribble(
    ~activity,
    "Art",
    "Butterfly Garden",
    "Circular Cement Walkway",
    "Clean up",
    "Drama",
    "Floor",
    "Handwashing",
    "Jungle Gym",
    "Large group",
    "Lunch",
    "Math",
    "Music",
    "Other",
    "Playhouses",
    "Sandbox",
    "Science",
    "Small group",
    "Snack",
    "Toileting",
    "Transition to inside",
    "Transition to outside",
    "Writing"
  )

  return(activity_types)

}
