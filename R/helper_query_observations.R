#' @title query a bird observation record
#'
#' @description The function included here ( query_bird_observation ) ...
#'
#' @export
#'
query_class_observations <- function(survey_id) {

  # survey_id <- as.integer(survey_id)

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

  print(class_observations)
  # return(class_observations)

}

# class_students <- query_class_observations() |>
#   dplyr::filter()
