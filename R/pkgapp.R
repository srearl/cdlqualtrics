# vim: set foldmethod=marker
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# library(shiny)

# Define UI for application that draws a histogram


#' @import shiny
#' @export

pkgapp <- function(options = list(port = 8001)) {

  shiny::shinyApp(
    ui      = ui,
    server  = server,
    options = options
  )

}
