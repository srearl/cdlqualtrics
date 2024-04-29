#'
#'
#'
#'
#'
#'
#' @note To facilitate search within the columns of a table but not globally
#' (i.e., remove the search bar), we set the dom to 'tp'. However, this
#' approach is deprecated (see: https://datatables.net/reference/option/dom)
#' and will not be supported as of datatables v3. At the time this app was
#' developed, the recommended approach was not available in Shiny.
#'
#' @export
#'
observation_expected_cols <- c(
  "survey_id",
  "start_date",
  "end_date",
  "status",
  "ip_address",
  "progress",
  "duration_in_seconds",
  "finished",
  "recorded_date",
  "response_id",
  "recipient_last_name",
  "recipient_first_name",
  "recipient_email",
  "external_reference",
  "location_latitude",
  "location_longitude",
  "distribution_channel",
  "user_language",
  "question",
  "response"            
)

fetch_survey_data <- function(survey_id) {

  # query qualtrics API

  suppressMessages(

    single_survey_df <- qualtRics::fetch_survey(
      surveyID = survey_id,
      verbose  = TRUE
    ) |>
      janitor::clean_names()

  )

  message("survey: ", survey_id, "rows: ", nrow(single_survey_df))


  # format observation data

  single_survey_df <- single_survey_df |> 
    dplyr::mutate(
      survey_id           = as.character(survey_id),
      start_date          = as.character(start_date),
      end_date            = as.character(end_date),
      progress            = as.integer(progress),
      duration_in_seconds = as.integer(duration_in_seconds),
      finished            = as.logical(finished),
      recorded_date       = as.character(recorded_date),
      dplyr::across(tidyselect::starts_with("q"), as.character)
    ) |> 
    dplyr::select(survey_id, tidyselect::everything())


  # remove line breaks from Q32

  if ("q32" %in% names(single_survey_df)) {

    single_survey_df$q32 <- gsub("[\r\n]", ".", single_survey_df$q32) 

  }


  # coordinates to numeric

  if ("location_latitude" %in% names(single_survey_df)) {

    single_survey_df$location_latitude <- as.numeric(single_survey_df$location_latitude)

  }

  if ("location_longitude" %in% names(single_survey_df)) {

    single_survey_df$location_longitude <- as.numeric(single_survey_df$location_longitude)

  }


  # wide to long

  single_survey_df <- single_survey_df |> 
    tidyr::pivot_longer(
      cols      = tidyr::matches("^Q[0-9]+"),
      names_to  = "question",
      values_to = "response"
    ) |> 
    dplyr::filter(!is.na(response))


  # write

  if (!all(colnames(single_survey_df) %in% c(observation_expected_cols))) {

    warning("unexpected data structure for survey ", survey_id, " (data not loaded)") 

  } else {

    # return(single_survey_df)

    DBI::dbWriteTable(
      conn      = csl_obs_db,
      name      = "observations",
      value     = single_survey_df,
      overwrite = FALSE,
      append    = TRUE,
      row.names = FALSE
    )

  }

}

fetch_survey_data_possibly <- purrr::possibly(
  .f        = fetch_survey_data,
  otherwise = NULL
)

# split(
#   x = surveys_most_recent,
#   f = surveys_most_recent$id
# ) |> 
#   {\(row) purrr::walk(.x = row, ~ fetch_survey_data_possibly(survey_id  = .x$id))}()
