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
server <- function(input, output, session) {

  # surveys --------------------------------------------------------------------

  surveys_data_reactive <- shiny::reactive({

    surveys <- query_surveys()

    return(surveys)

  }) |> shiny::bindEvent(input$query_database)


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

  }) |> shiny::bindEvent(input$surveys_data_view_rows_selected)



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

  output$behaviour_view <- echarts4r::renderEcharts4r({

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
        n        = dplyr::n(),
        per_cent = round((n / student_behaviours_sum) * 100)
      ) |>
      dplyr::ungroup() |>
      echarts4r::e_charts(response) |> 
      echarts4r::e_bar(per_cent, name = "behaviour", legend = FALSE) |>
      echarts4r::e_tooltip(trigger = "axis") |>
      echarts4r::e_x_axis(axisLabel = list(interval = 0, rotate = 315)) |>
      echarts4r::e_title(input$observation_students) |>
      echarts4r::e_grid(bottom = "40%") |>
      echarts4r::e_axis_labels(y = "per cent")

  })


  # update surveys ---------------------------------------------------------------

  new_surveys_reactive <- shiny::reactive({

    surveys_api <- qualtRics::all_surveys()
    surveys_api <- format_surveys(surveys_api)

    # here we query all surveys (i.e., not query_surveys())
    surveys_all_query <- glue::glue_sql(
      "SELECT * FROM surveys ;",
      .con = DBI::ANSI()
    )
    surveys_db  <- run_interpolated_query(surveys_all_query)

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

  }) |> shiny::bindEvent(input$check_for_updates)


  output$new_surveys_view <- DT::renderDT({

    if (!is.null(new_surveys_reactive())) {

      new_surveys_reactive() # |>
        # dplyr::select(
        #   id,
        #   name,
        #   creation_date,
        #   is_active,
        #   semester,
        #   year,
        #   class,
        #   reliability,
        #   status
        # )

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

  shiny::observeEvent(input$update_database, {

    shiny::req(nrow(new_surveys_reactive()) > 0)

    new_surveys <- new_surveys_reactive() |>
      dplyr::filter(status == "new")
      dplyr::select(-status)

    updated_surveys <- new_surveys_reactive() |>
      dplyr::filter(status == "updated")
      dplyr::select(-status)

    tryCatch({

      pool::poolWithTransaction(
        pool = this_pool,
        func = function(conn) {

          # add new surveys

          DBI::dbWriteTable(
            conn      = this_pool,
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

          glue::glue_sql("
            UPDATE surveys
            SET last_modified = { updated_surveys$last_modified }
            WHERE id = { updated_surveys$id }
            ;
            ",
            .con = DBI::ANSI()
          )

          # delete observations of updated surveys

          glue::glue_sql("
            DELETE from observations
            WHERE id = { updated_surveys$id }
            ;
            ",
            .con = DBI::ANSI()
          )

          # add observations for new and updated surveys

          split(
            x = new_surveys_reactive(),
            f = new_surveys_reactive()$id
          ) |> 
            {\(row) purrr::walk(.x = row, ~ fetch_survey_data_possibly(survey_id  = .x$id))}()

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
  shiny::observe(print(new_surveys_reactive() |> data.frame()))
  # shiny::observe(print(input$surveys_data_view_rows_selected))
  # shiny::observe(print(head(behaviour_view())))

} # close server
