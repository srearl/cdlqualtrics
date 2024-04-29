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
    # reflected in the response column (only!) associted with q2_ questions

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
    surveys_db  <- query_surveys()

    surveys_new <- dplyr::full_join(
      x = surveys_api,
      y = surveys_db |>
        dplyr::select(id) |>
        dplyr::mutate(source_db = 1),
      by = c("id")
    ) |>
      dplyr::filter(is.na(source_db)) |>
      dplyr::mutate(status = "new")

  }) |> shiny::bindEvent(input$check_for_updates)


  output$new_surveys_view <- DT::renderDT({

    new_surveys_reactive() |>
      dplyr::select(
        id,
        name,
        creation_date,
        is_active,
        semester,
        year,
        class,
        reliability,
        status
      )

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

    new_surveys_upload <- new_surveys_reactive() |>
      dplyr::select(
        id,
        name,
        owner_id,
        last_modified,
        creation_date,
        is_active,
        # last_modified_date,
        # creation_date_date,
        semester,
        year,
        class,
        reliability       
      )

    tryCatch({

      pool::poolWithTransaction(
        pool = this_pool,
        func = function(conn) {

          surveys_inserted <- DBI::dbWriteTable(
            conn      = this_pool,
            name      = "surveys",
            value     = new_surveys_upload,
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
              # last_modified_date,
              # creation_date_date,
              semester,
              year,
              class,
              reliability       
            )
          )

        }
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
  shiny::observe(print(head(new_surveys_reactive())))
  # shiny::observe(print(input$surveys_data_view_rows_selected))
  # shiny::observe(print(head(behaviour_view())))

} # close server
