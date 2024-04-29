#' @title query core bird survey data
#'
#' @description The functions included here ( query_surveys and query_survey )
#' facilitate querying core bird survey data from the database. query_surveys
#' supports querying the surveys table for project survey data whereas
#' query_survey facilitates querying content of a single survey so that the
#' details might be updated if needed.
#'
#' @note query project survey data
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

#' @note query details for a single survey

# query_survey <- function(survey) {

#   base_query <- "
#   SELECT
#     id,
#     name,
#     semester,
#     year,
#     class,
#     reliability,
#     last_modified_date AS last_modified,
#     creation_date AS created
#   FROM
#     surveys
#   WHERE
#     surveys.id = ?survey_id
#   ;
#   "

#   parameterized_query <- DBI::sqlInterpolate(
#     DBI::ANSI(),
#     base_query,
#     survey_id = survey
#   )

#   survey_table <- run_interpolated_query(parameterized_query)

#   return(survey_table)

# }

#' @note query survey id and date ranges

# query_survey_range <- function() {

#   base_query <- "
#   SELECT
#     surveys.id,
#     surveys.survey_date
#   FROM core_birds.surveys
#   ;
#   "

#   survey_ranges <- DBI::dbGetQuery(
#     conn      = this_pool,
#     statement = base_query
#   )

#   return(survey_ranges)

# }

# survey_ids_all <- query_survey_range()

# survey_ids_recent <- survey_ids_all |>
#   dplyr::filter(survey_date >= Sys.Date() - lubridate::years(2))
