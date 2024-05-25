#' @title Format survey data harvested from Qualtrics into a more readable form
#' and ready for upload to the cslobsdb database.
#'
#' @description \code{format_surveys} accepts as input a data frame of survey
#' data downloaded from Qualtrics sensu \code{qualtRics::all_surveys()}. The
#' query returns all surveys associated with the provided Qualtrics URL many of
#' which are not relevant. Among surveys filtered, only those that correspond
#' to an observation sheet are kept, surveys with "copy" or "- 2" in the name
#' are removed, and a targeted set of surveys of which the date could not be
#' determined are removed. Year, semester, and class are estimated from file
#' metadata. Dates are formatted, and field names are cleaned (per janitor).
#' Although not accessible through the web interface, querying survey data
#' through the API can return multiple survey instances for a given year,
#' semester, class, reliability combination. It is not clear the reason for
#' more than one instance of the same survey, but the observation data are
#' different among them. Only the most recently modified survey among a
#' duplicate set is returned.
#'
#' import dplyr
#' import shiny
#' importFrom stringr str_extract
#' importFrom janitor clean_names
#'
#' @param surveys
#' (character) Data frame of surveys resulting from a call to
#' `qualtRics::all_surveys()`
#'
#' @return A formatted data frame of Qualtrics survey data
#'
#' @export
#'
format_surveys <- function(surveys) {

  # `spring` is misspelled in survey SV_6llGtw3tYcJg6hf
  if (any(grepl("SV_6llGtw3tYcJg6hf", surveys$id, ignore.case = TRUE))) {

    surveys[surveys$id == "SV_6llGtw3tYcJg6hf", ]$name <- "Reliability Spring 2018 CSL Observation Sheet T/TH Two's & Three's"

  }

  observation_surveys <- surveys[grepl("spring|summer|fall", surveys$name, ignore.case = TRUE), ]

  surveys_filtered <- observation_surveys |>
    dplyr::mutate(
      # date and timestamp actions
      lastModified = as.POSIXct(
        x      = lastModified,
        format = "%Y-%m-%dT%H:%M:%SZ"
      ),
      creationDate = as.POSIXct(
        x      = creationDate,
        format = "%Y-%m-%dT%H:%M:%SZ"
      ),
      semester = dplyr::case_when(
        grepl("spring", name, ignore.case = TRUE) ~ "spring",
        grepl("summer", name, ignore.case = TRUE) ~ "summer",
        grepl("fall",   name, ignore.case = TRUE) ~ "fall",
        TRUE ~ NA_character_
      ),
      year = stringr::str_extract(name, "[0-9]{4,}"),
      year = as.integer(year),
      # fix summer sans year in name
      year = dplyr::case_when(
        id == "SV_3Po51xk4m7SBxEq" ~ 2022,
        TRUE ~ year
      ),
      class = dplyr::case_when(
        grepl("t.th", name, ignore.case = TRUE) & grepl("two", name, ignore.case = TRUE) ~ "TTh_23",
        grepl("t.th", name, ignore.case = TRUE) & (grepl("three", name, ignore.case = TRUE) & !grepl("two", name, ignore.case = TRUE)) ~ "TTh_three",
        grepl("t.th", name, ignore.case = TRUE) & grepl("multi", name, ignore.case = TRUE) ~ "TTh_multi",
        grepl("t.th", name, ignore.case = TRUE) & grepl("parent|toddler", name, ignore.case = TRUE) ~ "TTh_PT",
        grepl("t.th|tth", name, ignore.case = TRUE) & grepl("older", name, ignore.case = TRUE) ~ "TTh_older",
        grepl("t.th|tth", name, ignore.case = TRUE) & grepl("younger", name, ignore.case = TRUE) ~ "TTh_younger",
        grepl("mwf", name, ignore.case = TRUE) & grepl("two", name, ignore.case = TRUE) ~ "MWF_23",
        grepl("mwf", name, ignore.case = TRUE) & (grepl("three", name, ignore.case = TRUE) & !grepl("two", name, ignore.case = TRUE)) ~ "MWF_three",
        grepl("mwf", name, ignore.case = TRUE) & grepl("multi", name, ignore.case = TRUE) ~ "MWF_multi",
        grepl("mwf", name, ignore.case = TRUE) & grepl("parent|toddler", name, ignore.case = TRUE) ~ "MWF_PT",
        grepl("mwf", name, ignore.case = TRUE) & grepl("older", name, ignore.case = TRUE) ~ "MWF_older",
        grepl("mwf", name, ignore.case = TRUE) & grepl("younger", name, ignore.case = TRUE) ~ "MWF_younger",
        grepl("pre.k", name, ignore.case = TRUE) ~ "Pre_K",
        # generic summer classes
        grepl("older", name, ignore.case = TRUE) & !(grepl("mwf", name, ignore.case = TRUE) & !grepl("tth", name, ignore.case = TRUE)) ~ "older",
        grepl("younger", name, ignore.case = TRUE) & !(grepl("mwf", name, ignore.case = TRUE) & !grepl("tth", name, ignore.case = TRUE)) ~ "younger",
        TRUE ~ NA
      ),
      reliability = dplyr::case_when(
        grepl("reliability", name, ignore.case = TRUE) ~ TRUE,
        TRUE ~ FALSE
      )
    ) |>
    janitor::clean_names()

  # summarise to identify the details of the surveys where the last_modified_date
  # is the most recent for a given combination of semester, year, class, and
  # reliability

  most_recent <- surveys_filtered |>
    dplyr::group_by(
      semester,
      year,
      class,
      reliability
    ) |>
    dplyr::summarise(latest = max(last_modified))

  # use the most up-to-date surveys identified in the pervious step to get all
  # survey details of all of the most-recently updated version of surveys

  surveys_most_recent <- surveys_filtered |>
    dplyr::right_join(
      most_recent,
      by = c(
        "semester",
        "year",
        "class",
        "reliability",
        "last_modified" = "latest"
      )
    ) |>
    dplyr::mutate(
      last_modified = as.character(last_modified),
      creation_date = as.character(creation_date)
    )


  # check that all semester year class are populated

  if (
    any(
      is.na(surveys_most_recent$semester),
      is.na(surveys_most_recent$year),
      is.na(surveys_most_recent$class)
    )
  ) {

    shiny::showNotification(
      ui          = "semester, year, or class not determined for at least one survey",
      duration    = 5,
      closeButton = TRUE,
      type        = "error"
    )

    stop()

  }


  return(surveys_most_recent)

}
