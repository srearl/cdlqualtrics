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

  #   birds <- birds |>
  #   # dplyr::filter(!is.na(bird_count)) |>
  #   tidyr::pivot_wider(
  #     names_from  = distance,
  #     values_from = bird_count
  #     ) |>
  #   dplyr::select(
  #     dplyr::any_of(
  #       c(
  #         "id",
  #         "survey_id",
  #         "code",
  #         "common_name",
  #         "dist_0_5"   = "0-5",
  #         "dist_5_10"  = "5-10",
  #         "dist_10_20" = "10-20",
  #         "dist_20_40" = "20-40",
  #         "dist_gt_40" = "40+",
  #         "FT",
  #         "seen",
  #         "heard",
  #         "direction",
  #         "notes"
  #       )
  #     )
  #   )

  # print(class_observations)
  return(class_observations)

}

# class_students <- query_class_observations() |>
#   dplyr::filter()
