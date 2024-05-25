#' @title Query survey data from sqlite database
#'
#' @description The function included here (\code{query_surveys}) queries all
#' survey data in the sqlite database. Additionally, the number of observation
#' records associated with each survey is calculated and returned as part of
#' the result.
#'
#' @note consider an inner join
#'
#' importFrom glue glue_sql
#' importFrom DBI ANSI
#'
#' @export
#'
query_surveys <- function() {

  base_query <- glue::glue_sql("
    SELECT
      surveys.id,
      surveys.name,
      surveys.semester,
      surveys.year,
      surveys.class,
      surveys.reliability,
      obs_count.obs,
      surveys.last_modified,
      surveys.creation_date AS created
    FROM
      surveys
    JOIN
      (
        SELECT
          survey_id,
          count(*) AS obs
        FROM
          observations
        GROUP BY
          survey_id
      ) AS obs_count ON (obs_count.survey_id = surveys.id)
    ORDER BY
      surveys.last_modified DESC
    ;
    ",
    .con = DBI::ANSI()
  )

  surveys_table <- run_interpolated_query(base_query)

  return(surveys_table)

}
