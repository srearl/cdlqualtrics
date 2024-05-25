#' @title UI component of the cslqualtrics Shiny application
#'
#' @description The UI component of the cslqualtrics Shiny application.
#' Developed as a single UI that is not drawing upon modules.
#'
#' import shiny
#' import bslib
#' importFrom DT DTOutput
#'
#' @export
#'
ui <- bslib::page_navbar(

  title    = paste0("CSL: ", round(rnorm(1), 2)),
  position = c("static-top"),
  theme    = this_theme,

  bslib::nav_panel(
    title = "explore data",
    shiny::p("explore data"),

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

      bslib::accordion(
        open = FALSE,

        bslib::accordion_panel(
          title = "behaviour by student",

          bslib::card(
            shiny::plotOutput(
              outputId = "behaviour_view",
              height   = "600px"
            )
          ) # close card
        ), # close accordion_panel

        bslib::accordion_panel(
          title = "behaviour by activity (location)",

          bslib::card(
            shiny::plotOutput(
              outputId = "location_view",
              height   = "600px"
            )
          )
        ), # close accordion_panel

        bslib::accordion_panel(
          title = "behaviour by TA",

          bslib::card(
            shiny::tableOutput("ta_view")
          )
        ) # close accordion_panel

      ) # close accordion

    ), # close row - location by behaviour

    # debugging
    # br()
    # shiny::verbatimTextOutput(outputId = "mod_vals")

  ), # close nav_panel explore data

  bslib::nav_panel(
    title = "utilities",
    shiny::p("database administration"),

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

    ) # close top fluidRow

  ) # close nav_panel utilities

) # close page_navbar
