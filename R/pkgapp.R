#' @title Launch a Shiny shinyApp
#'
#' @description Helper function that constructs the \code{shiny::shinyApp}
#'
#' @importFrom shiny shinyApp
#'
#' @export
#'
pkgapp <- function(options = list(port = 8001)) {

  shiny::shinyApp(
    ui      = ui,
    server  = server,
    options = options
  )

}
