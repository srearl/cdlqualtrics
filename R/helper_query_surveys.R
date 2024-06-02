#' @title Query survey data from sqlite database
#'
#' @description The functions included here (\code{query_surveys} and
#' \code{query_surveys_semester}) query all survey data in the sqlite database
#' after 2015 or for a particular year and semester, respectively.
#' Additionally, the number of observation records associated with each survey
#' is calculated and returned as part of the result.
#'
#' @note The inner join constrains the return to surveys that have at least one
#' corresponding observation record in the database.
#'
#' importFrom glue glue_sql
#' importFrom DBI ANSI
#'
#' @export
#'
query_surveys <- function(query_conn) {

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
    WHERE surveys.year > 2015
    ORDER BY
      surveys.last_modified DESC
    ;
    ",
    .con = DBI::ANSI()
  )

  surveys_table <- run_interpolated_query(base_query)

  return(surveys_table)

}

#' @note \code{query_surveys_semester} queries surveys associated with a
#' particular year and semester.
#'
#' @note The inner join constrains the return to surveys that have at least one
#' corresponding observation record in the database.
#'
#' importFrom glue glue_sql
#' importFrom DBI ANSI
#'
#' @export
#'
query_surveys_semester <- function(
  this_year,
  this_semester
) {

  this_year <- as.integer(this_year)

  base_query <- glue::glue_sql("
    SELECT
      surveys.id,
      surveys.name,
      surveys.semester,
      surveys.year,
      surveys.class,
      surveys.reliability,
      -- obs_count.obs,
      surveys.last_modified,
      surveys.creation_date AS created
    FROM
      surveys
    -- JOIN
    --   (
    --     SELECT
    --       survey_id,
    --       count(*) AS obs
    --     FROM
    --       observations
    --     GROUP BY
    --       survey_id
    --   ) AS obs_count ON (obs_count.survey_id = surveys.id)
    WHERE
      surveys.semester = { this_semester } AND
      surveys.year = { this_year}
    ORDER BY
      surveys.last_modified DESC
    ;
    ",
    .con = DBI::ANSI()
  )

  surveys_table <- run_interpolated_query(base_query)

  # print(surveys_table)
  return(surveys_table)

}
