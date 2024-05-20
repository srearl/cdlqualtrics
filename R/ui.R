#' @export

ui <- bslib::page_navbar(

  title    = paste0("CSL: ", round(rnorm(1), 2)),
  position = c("static-top"),
  theme    = this_theme,

  bslib::nav_panel(
    title = "utilities",
    p("database administration"),

    shiny::fluidRow(

      bslib::card(

        bslib::layout_sidebar(
          fillable = TRUE,
          sidebar  = bslib::sidebar(
            position = "right",
            open     = TRUE,

            shiny::actionButton(
              inputId = "authenticate",
              label   = "authenticate",
              class   = "btn-success"
            ),

            "SURVEYS",

            bslib::input_task_button(
              id    = "check_for_updates",
              label = "check for updates"
              # class   = "btn-success"
            ),

            bslib::input_task_button(
              id    = "update_database",
              label = "add updates"
              # class   = "btn-success"
            ),

            "OBSERVATIONS"

          ), # close sidebar
          DT::DTOutput("new_surveys_view"),
        ) # close layout_sidebar

      ) # close card

    ), # close top fluidRow

  ),

  bslib::nav_panel(
    title = "explore data",

    # shiny::fluidRow(

    #   shiny::column(
    #     width = 2,
    #     shiny::actionButton(
    #       inputId = "query_database",
    #       label   = "load data",
    #       class   = "btn-success"
    #     )
    #   ),

    #   shiny::column(width = 10)

    # ), # close fluidRow

    shiny::br(),

    shiny::fluidRow(

      bslib::card(

        bslib::layout_sidebar(
          fillable = TRUE,
          sidebar  = bslib::sidebar(
            position = "right",
            open     = TRUE,

            shiny::actionButton(
              inputId = "query_database",
              label   = "load data",
              class   = "btn-success"
            ),

            shiny::selectInput(
              inputId   = "observation_students",
              label     = "students",
              choices   = "",
              multiple  = FALSE,
              selectize = FALSE
            )

            # DT::DTOutput("observations_data_students_view")

          ), # close sidebar
          DT::DTOutput("surveys_data_view"),
        ) # close layout_sidebar

      ) # close card

    ), # close top fluidRow

    shiny::fluidRow(

      bslib::card(
        echarts4r::echarts4rOutput("behaviour_view")
      ) # close card

    ), # close row

    # br()
    # shiny::verbatimTextOutput(outputId = "mod_vals")

  ) # close nav_panel #2


) # close page_navbar
