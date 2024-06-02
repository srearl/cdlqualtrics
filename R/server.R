#' @title server component of the cslqualtrics Shiny application
#'
#' @description The server component of the cslqualtrics Shiny application.
#' Developed as a single file that is not drawing upon modules.
#'
#' @note To facilitate search within the columns of a table but not globally
#' (i.e., remove the search bar), we set the dom to 'tp'. However, this
#' approach is deprecated (see: https://datatables.net/reference/option/dom)
#' and will not be supported as of datatables v3. At the time this app was
#' developed, the recommended approach was not available in Shiny.
#'
#' import shiny
#' import dplyr
#' import ggplot2
#' import qualtRics
#' import pool
#' importFrom DT renderDT JS
#' importFrom glue glue_sql
#' importFrom DBI ANSI dbWriteTable
#' importFrom purrr walk possibly
#' importFrom lobstr tree
#'
#' @export
#'
server <- function(input, output, session) {

  # force stop -----------------------------------------------------------------

  session$onSessionEnded(function() {

    cat("close pool from session\n")

    shiny::observe(
      pool::poolClose(connection$this_conn)
    )

    shiny::stopApp()

  })


  # connection -----------------------------------------------------------------

  connection <<- shiny::reactiveValues(this_conn = NULL)

  shiny::observeEvent(input$load_database, {

    if (file.exists(input$sqlite_file)) {

      tryCatch({

        connection$this_conn <- pool::dbPool(
          drv      = RSQLite::SQLite(),
          dbname   = input$sqlite_file,
          shutdown = TRUE
        )

        DBI::dbExecute(
          conn      = connection$this_conn,
          statement = "PRAGMA foreign_keys = ON ;"
        )

        shiny::showNotification(
          ui          = "connected",
          duration    = 5,
          closeButton = TRUE,
          type        = "message"
        )

      }, error = function(err) {

          shiny::showNotification(
            ui          = paste("could not connect: ", err),
            duration    = NULL,
            closeButton = TRUE,
            type        = "error"
          )

        })

    } else {

      shiny::showNotification(
        ui          = paste("file does not exist"),
        duration    = 5,
        closeButton = TRUE,
        type        = "warning"
      )
    }

  })

  test_data_reactive <- shiny::reactive({

    some_stuff <- DBI::dbGetQuery(
      conn = connection$this_conn,
      statement = "select * from surveys limit 3 ;"
    )

    return(some_stuff)

  }) |>
    shiny::bindEvent(input$test_database)


  # surveys --------------------------------------------------------------------

  surveys_data_reactive <- shiny::reactive({

    surveys <- query_surveys()

    return(surveys)

  }) |>
    shiny::bindEvent(input$query_database)


  output$surveys_data_view <- DT::renderDT({

    surveys_data_reactive()

  },
    class      = c("compact"),
    filter     = "top",
    extensions = c("FixedHeader"),
    plugins    = c("ellipsis"),
    escape     = FALSE,
    selection  = "single",
    rownames   = FALSE,
    options    = list(
      dom           = "tp", # deprecated in datatables (see note)
      searching     = TRUE,
      scrollX       = TRUE,
      bFilter       = 1,
      bLengthChange = FALSE,
      bPaginate     = FALSE,
      bSort         = TRUE,
      autoWidth     = FALSE,
      pageLength    = 10,
      fixedHeader   = FALSE,
      columnDefs    = list(
        list(
          width   = "35%",
          targets = c(1)
        ),
        list(
          targets = c(0),
          render  = DT::JS("$.fn.dataTable.render.ellipsis(10)")
        ),
        list(
          targets = c(1),
          render  = DT::JS("$.fn.dataTable.render.ellipsis(50)")
        ),
        list(
          targets    = c(0, 6, 7, 8),
          searchable = FALSE
        )
      )
    )
  ) # close output$surveys_data_view


  # observations ---------------------------------------------------------------

  observations_data_reactive <- shiny::reactive({

    survey <- surveys_data_reactive()[input$surveys_data_view_rows_selected, ]$id

    observations <- query_class_observations(survey)

    return(observations)

  }) |>
    shiny::bindEvent(input$surveys_data_view_rows_selected)


  # students -------------------------------------------------------------------

  # generate a list of students in a class to populate the selector (for
  # plotting)

  shiny::observe({

    students <- observations_data_reactive() |>
      dplyr::filter(grepl("^q2_", question, ignore.case = TRUE)) |>
      dplyr::distinct(response) |>
      dplyr::arrange(response) |>
      dplyr::rename(students = response)

    shiny::updateSelectInput(
      inputId = "observation_students",
      choices = students
    )

  })


  # behaviour ------------------------------------------------------------------

  output$behaviour_view <- shiny::renderPlot({

    # get the response ids of all data corresponding to the selected student by
    # filtering observation data on the name of that student (precisely!)
    # reflected in the response column (only!) associated with q2_ questions

    student_responses_ids <- observations_data_reactive()[
    observations_data_reactive()$response == input$observation_students &
    grepl("^q2_", observations_data_reactive()$question, ignore.case = TRUE),
    ]$response_id

    # filter all observation data by the response ids corresponding to the
    # student of interest

    student_observations_data <- observations_data_reactive()[
    observations_data_reactive()$response_id %in% c(student_responses_ids),
    ]

    # for behaviours, pare data to only q4

    student_behaviours_sum <- student_observations_data |>
      dplyr::filter(grepl("^q4$", question, ignore.case = TRUE)) |>
      nrow()

    student_observations_data |>
      dplyr::filter(grepl("^q4$", question, ignore.case = TRUE)) |>
      dplyr::group_by(response) |>
      dplyr::summarise(
        n       = dplyr::n(),
        percent = round((n / student_behaviours_sum) * 100)
      ) |>
      dplyr::ungroup() |>
      dplyr::full_join(
        y  = cslqualtrics::behaviour_types,
        by = c("response" = "behaviour")
      ) |>
      dplyr::mutate(
        percent = dplyr::case_when(
          is.na(percent) ~ 0,
          TRUE ~ percent
        )
      ) |>
      dplyr::arrange(
        type,
        response
      ) |>
      dplyr::mutate(
        response = factor(
          x      = response,
          levels = behaviour_levels
        )
      ) |>
      ggplot2::ggplot(
        mapping = ggplot2::aes(
          x    = response,
          y    = percent,
          fill = type
        )
      ) +
    ggplot2::geom_bar(
      stat        = "identity",
      show.legend = TRUE
    ) +
    ggplot2::scale_fill_manual(
      "behaviour type",
      values = behaviour_type_colors,
      drop   = FALSE
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = 315,
        vjust = 1,
        hjust = 0
      ),
      axis.title.x     = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      text             = ggplot2::element_text(size = 20)
    ) +
    ggplot2::ylim(0, 60) +
    ggplot2::ggtitle(input$observation_students)

  })


  # behaviour by activity (location) -------------------------------------------

  output$location_view <- shiny::renderPlot({

    dplyr::inner_join(
      observations_data_reactive() |>
        dplyr::filter(grepl("q4$", question, ignore.case = TRUE)) |>
        dplyr::select(
          response_id,
          behaviour = response
        ),
      observations_data_reactive() |>
        dplyr::filter(grepl("q31$", question, ignore.case = TRUE)) |>
        dplyr::select(
          response_id,
          activity = response
        ),
      by = "response_id"
    ) |>
      dplyr::count(behaviour, activity) |>
      # full_join to ensure all behaviour types are plotted
      dplyr::full_join(
        y = cslqualtrics::behaviour_types,
        by = c("behaviour")
      ) |>
      dplyr::arrange(type) |>
      dplyr::mutate(
        behaviour = factor(
          behaviour,
          levels = behaviour_levels
        )
      ) |>
      # ensure all activity types are plotted
      dplyr::full_join(
        cslqualtrics::activity_types,
        by = c("activity")
      ) |>
      ggplot2::ggplot(
        ggplot2::aes(
          x    = activity,
          y    = behaviour,
          fill = n
        )
      ) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_distiller(
      palette   = "YlOrRd",
      direction = 1
    ) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(
        angle = 315,
        vjust = 1,
        hjust = 0
      ),
      text = ggplot2::element_text(size = 20)
    )

  })


  # behaviour by TA ------------------------------------------------------------

  output$ta_view <- shiny::renderTable(
    striped = TRUE,
    hover   = TRUE,
    border  = TRUE,
    spacing = c("s"),
    {

      ta_behaviour <- dplyr::inner_join(
        observations_data_reactive() |>
          dplyr::filter(grepl("q4$", question, ignore.case = TRUE)) |>
          dplyr::select(
            response_id,
            behaviour = response
          ),
        observations_data_reactive() |>
          dplyr::filter(grepl("q1$", question, ignore.case = TRUE)) |>
          # remove special character esp. colon for time
          dplyr::mutate(response = gsub(":|@|#|'|\\.", "", response)) |>
          dplyr::select(
            response_id,
            TA = response
          ),
        by = "response_id"
      )

      ta_total <- ta_behaviour |>
        dplyr::group_by(TA) |>
        dplyr::summarise(total = dplyr::n()) |>
        dplyr::ungroup()

      ta_behaviour <- ta_behaviour |>
        dplyr::count(behaviour, TA) |>
        tidyr::pivot_wider(
          names_from  = behaviour,
          values_from = n
        ) |>
        dplyr::select(
          TA,
          tidyselect::any_of(behaviour_levels)
        ) |> 
        dplyr::left_join(
          ta_total,
          by = c("TA")
        ) |>
        dplyr::arrange(TA)

      return(ta_behaviour)

    })


  # update surveys -------------------------------------------------------------

  new_surveys_reactive <- shiny::reactive({

    surveys_api <- qualtRics::all_surveys()
    surveys_api <- format_surveys(surveys_api)

    # here we query all surveys as opposed to query_surveys() that only returns
    # surveys for which there are corresponding observation records

    surveys_all_query <- glue::glue_sql(
      "SELECT * FROM surveys ;",
      .con = DBI::ANSI()
    )
    surveys_db <- run_interpolated_query(surveys_all_query)

    surveys_new <- dplyr::full_join(
      x = surveys_api,
      y = surveys_db |>
        dplyr::select(id) |>
        dplyr::mutate(source_db = 1),
      by = c("id")
    ) |>
      dplyr::filter(is.na(source_db)) |>
      dplyr::mutate(status = "new") |>
      dplyr::select(-source_db)

    surveys_updated <- dplyr::inner_join(
      x = surveys_api,
      y = surveys_db |>
        dplyr::select(id, last_modified) |>
        dplyr::rename(last_modified_db = last_modified),
      by = c("id"),
      suffix = c("_api", "_db")
    ) |>
      dplyr::filter(last_modified > last_modified_db) |>
      dplyr::mutate(status = "updated") |>
      dplyr::select(-last_modified_db)

    new_or_updated <- dplyr::bind_rows(
      surveys_new,
      surveys_updated
    )

    if (nrow(new_or_updated) > 0) {

      return(new_or_updated)

    } else {

      shiny::showNotification(
        ui          = "database is up to date",
        duration    = 5,
        closeButton = TRUE,
        type        = "message"
      )

      return(NULL)

    }

  }) |>
    shiny::bindEvent(input$check_for_updates)


  output$new_surveys_view <- DT::renderDT({

    if (!is.null(new_surveys_reactive())) {

      new_surveys_reactive()

    }

  },
    class      = c("compact"),
    filter     = "top",
    extensions = c("FixedHeader"),
    plugins    = c("ellipsis"),
    escape     = FALSE,
    selection  = "none",
    rownames   = FALSE,
    options    = list(
      dom           = "tp", # deprecated in datatables (see note)
      searching     = TRUE,
      scrollX       = TRUE,
      bFilter       = 1,
      bLengthChange = FALSE,
      bPaginate     = FALSE,
      bSort         = TRUE,
      autoWidth     = TRUE,
      pageLength    = 10,
      fixedHeader   = FALSE,
      columnDefs    = list(
        list(
          width   = "35%",
          targets = c(1)
        ),
        list(
          targets = c(0),
          render  = DT::JS("$.fn.dataTable.render.ellipsis(10)")
        ),
        list(
          targets = c(1),
          render  = DT::JS("$.fn.dataTable.render.ellipsis(50)")
        ),
        list(
          targets    = c(0),
          searchable = FALSE
        )
      )
    )
  ) # close output$new_surveys_view

  # sqlite.surveys.cols
  #   "id"
  #   "name"
  #   "owner_id"
  #   "last_modified"
  #   "creation_date"
  #   "is_active"
  #   "semester"
  #   "year"
  #   "class"
  #   "reliability"

  shiny::observeEvent(input$update_surveys, {

    shiny::req(nrow(new_surveys_reactive()) > 0)

    new_surveys <- new_surveys_reactive() |>
      dplyr::filter(status == "new") |>
      dplyr::select(-status)

    updated_surveys <- new_surveys_reactive() |>
      dplyr::filter(status == "updated") |>
      dplyr::select(-status)

    tryCatch({

      pool::poolWithTransaction(
        pool = connection$this_conn,
        func = function(transaction_conn) {

          # add new surveys

          DBI::dbWriteTable(
            conn      = transaction_conn,
            name      = "surveys",
            value     = new_surveys,
            overwrite = FALSE,
            append    = TRUE,
            row.names = FALSE,
            col.names = c(
              id,
              name,
              owner_id,
              last_modified,
              creation_date,
              is_active,
              semester,
              year,
              class,
              reliability
            )
          )

          # update time of updated surveys

          update_last_modified <- glue::glue_sql("
            UPDATE surveys
            SET last_modified = { updated_surveys$last_modified }
            WHERE id = { updated_surveys$id }
            ;
            ",
            .con = DBI::ANSI()
          )

          purrr::walk(update_last_modified, ~ DBI::dbExecute(statement = .x, conn = transaction_conn))

          # delete observations of updated surveys

          delete_outdated_obs <- glue::glue_sql("
            DELETE from observations
            WHERE survey_id IN ({ updated_surveys$id* })
            ;
            ",
            .con = DBI::ANSI()
          )

          DBI::dbExecute(
            conn      = transaction_conn,
            statement = delete_outdated_obs
          )

          # add observations for new and updated surveys

          fetch_survey_data_possibly <- purrr::possibly(
            .f        = cslqualtrics::fetch_survey_data,
            otherwise = NULL
          )

          split(
            x = new_surveys_reactive(),
            f = new_surveys_reactive()$id
          ) |>
            {\(row) purrr::walk(.x = row, ~ fetch_survey_data_possibly(survey_id  = .x$id, connection = transaction_conn))}()

          shiny::showNotification(
            ui          = "update complete",
            duration    = 8,
            closeButton = TRUE,
            type        = "message"
          )

        } # close poolWithTransaction func
      ) # close poolWithTransaction

    }, warning = function(warn) {

        shiny::showNotification(
          ui          = paste("there is a warning:  ", warn),
          duration    = NULL,
          closeButton = TRUE,
          type        = "warning"
        )

      }, error = function(err) {

        shiny::showNotification(
          ui          = paste("there was an error:  ", err),
          duration    = NULL,
          closeButton = TRUE,
          type        = "error"
        )

      }) # close upload try catch

  }) # close shiny::observeEvent(input$update_database)

  # update observations --------------------------------------------------------

  shiny::observeEvent(input$update_observations, {

    shiny::isolate({
      year_input     <- input$observations_year
      semester_input <- input$observations_semester
    })

    surveys_to_update <- query_surveys_semester(
      this_year     = year_input,
      this_semester = semester_input
    )

    if (nrow(surveys_to_update) > 0) {

      tryCatch({

        pool::poolWithTransaction(
          pool = connection$this_conn,
          func = function(transaction_conn) {

            # delete observations of updated surveys

            delete_outdated_obs <- glue::glue_sql("
              DELETE from observations
              WHERE survey_id IN ({ surveys_to_update$id* })
              ;
              ",
              .con = DBI::ANSI()
            )

            DBI::dbExecute(
              conn      = transaction_conn,
              statement = delete_outdated_obs
            )

            # add observations for new and updated surveys

            fetch_survey_data_possibly <- purrr::possibly(
              .f        = cslqualtrics::fetch_survey_data,
              otherwise = NULL
            )

            split(
              x = surveys_to_update,
              f = surveys_to_update$id
            ) |>
              {\(row) purrr::walk(.x = row, ~ fetch_survey_data_possibly(survey_id  = .x$id, connection = transaction_conn))}()

          } # close poolWithTransaction func
        ) # close poolWithTransaction

      }, warning = function(warn) {

          shiny::showNotification(
            ui          = paste("there is a warning:  ", warn),
            duration    = NULL,
            closeButton = TRUE,
            type        = "warning"
          )

        }, error = function(err) {

          shiny::showNotification(
            ui          = paste("there was an error:  ", err),
            duration    = NULL,
            closeButton = TRUE,
            type        = "error"
          )

        }) # close upload try catch

    } else {

      shiny::showNotification(
        ui          = "nothing found try updating surveys first",
        duration    = NULL,
        closeButton = TRUE,
        type        = "message"
      )

    }

  })


  # debugging ------------------------------------------------------------------

  output$mod_vals <- shiny::renderPrint({

    lobstr::tree(
      shiny::reactiveValuesToList(
        x = input,
        all.names = TRUE
      )
    )
  })

  # shiny::observe(print(surveys_data_reactive()))
  # shiny::observe(print(surveys_data_reactive()[input$surveys_data_view_rows_selected, ]$id))
  # shiny::observe(print(head(observations_data_reactive())))
  # shiny::observe(print(new_surveys_reactive() |> data.frame()))
  # shiny::observe(print(input$surveys_data_view_rows_selected))
  # shiny::observe(print(head(behaviour_view())))
  # shiny::observe(print(input$sqlite_file))
  shiny::observe(print(test_data_reactive()))
  shiny::observe(if(!is.null(connection$this_conn)) { print(DBI::dbGetInfo(connection$this_conn)) })
  # shiny::observe(print(DBI::dbGetInfo(connection$this_conn)))
  # shiny::observe(print(connection$this_conn))
  shiny::observe(print(is.null(connection$this_conn)))

} # close server
