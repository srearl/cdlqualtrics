#' @title R code to construct behaviour_types package data object
#'
#' @description R code to construct the \code{behaviour_types} data object in
#' the cslqualtrics package; included for reference (not exported).
#'
generate_behaviour_types <- tibble::tribble(
  ~type, ~behaviour,
  "cognitive", "persistence",
  "cognitive", "planning",
  "cognitive", "problem solving",
  "emotional", "physical empathy",
  "emotional", "verbally expresses empathy",
  "emotional", "verbally expresses others' emotions",
  "emotional", "verbally expresses own emotions",
  "prosocial", "helpfulness",
  "prosocial", "interactive play",
  "prosocial", "sharing",
  "prosocial", "turn taking",
  "aggression", "instrumental aggression",
  "aggression", "physical aggression",
  "aggression", "relational aggression",
  "aggression", "verbal aggression",
  "inappropriate behaviors", "crying/tantrums/fits",
  "inappropriate behaviors", "distracting others",
  "inappropriate behaviors", "loner",
  "inappropriate behaviors", "not following directions",
  "inappropriate behaviors", "refusing to take turns",
  "inappropriate behaviors", "shy",
  "inappropriate behaviors", "verbally inappropriate"
)
