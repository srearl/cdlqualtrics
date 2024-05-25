#' @title Query observations associated with a survey
#'
#' @description Queries from the sqlite database all observations associated
#' with an individual survey.
#'
#' importFrom glue glue_sql
#' importFrom DBI ANSI
#'
#' @export
#'
query_class_observations <- function(survey_id) {

  parameterized_query <- glue::glue_sql("
    SELECT
      response_id,
      question,
      response
    FROM
      observations
    WHERE
      survey_id = { survey_id }
    ;
    ",
    .con = DBI::ANSI()
  )

  class_observations <- run_interpolated_query(parameterized_query)

  # print(class_observations)
  return(class_observations)

}
