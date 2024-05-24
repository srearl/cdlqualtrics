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
        # echarts4r::echarts4rOutput("behaviour_view")
        shiny::plotOutput(
          outputId = "behaviour_view",
          height   = "600px"
        )
      ) # close card

    ), # close row

    shiny::fluidRow(

      bslib::accordion(
        open = FALSE,

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
          title = "another panel",

          bslib::card(
            "text in a card in an accordian in a row"
          ),
          bslib::card(
            "1 text in a card in an accordian in a row",
            "2 text in a card in an accordian in a row",
            "3 text in a card in an accordian in a row",
            "4 text in a card in an accordian in a row",
            "5 text in a card in an accordian in a row"
          )
        ) # close accordion_panel

      ) # close accordion

    ), # close row - location by behaviour

    # br()
    # shiny::verbatimTextOutput(outputId = "mod_vals")

  ) # close nav_panel #2


) # close page_navbar
