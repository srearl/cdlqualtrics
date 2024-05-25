#' @title R code to construct behaviour_types package data object
#'
#' @description R code to construct the \code{behaviour_types} data object in
#' the cslqualtrics package; included for reference (not exported).
#'
#' importFrom tibble tribble
#'
#' @examples
#' \dontrun{
#' behaviour_types <- generate_behaviour_types()
#' usethis::use_data(behaviour_types, overwrite = TRUE)
#' }
#'
generate_behaviour_types <- function() {

  behaviour_types <- tibble::tribble(
    ~type, ~behaviour, ~color,
    "Aggression", "Instrumental Agression", "#67001F",
    "Aggression", "Physical Agression", "#67001F",
    "Aggression", "Relational Agression", "#67001F",
    "Aggression", "Verbal Aggression", "#67001F",
    "Cognitive", "Problem Solving", "#AA9486",
    "Cognitive", "Persistance", "#AA9486",
    "Cognitive", "Planning", "#AA9486",
    "Emotional", "Verbally Expresses Own Emotions", "#B6854D",
    "Emotional", "Verbally Expresses Empathy", "#B6854D",
    "Emotional", "Physical Empathy", "#B6854D",
    "Emotional", "Verbally Expresses Others' Emotions", "#B6854D",
    "Prosocial", "Interactive Play", "#39312F",
    "Prosocial", "Helpfullness", "#39312F",
    "Prosocial", "Sharing", "#39312F",
    "Prosocial", "Turn taking", "#39312F",
    "Inappropriate Behaviors", "Crying / tantrums / fits", "#EAD3BF",
    "Inappropriate Behaviors", "Distracting others", "#EAD3BF",
    "Inappropriate Behaviors", "Not following directions", "#EAD3BF",
    "Inappropriate Behaviors", "Refusing to take turns", "#EAD3BF",
    "Inappropriate Behaviors", "Verbally inappropriate", "#EAD3BF",
    "Inappropriate Behaviors", "Loner", "#EAD3BF",
    "Inappropriate Behaviors", "Shy", "#EAD3BF"
  )

  return(behaviour_types)

}
