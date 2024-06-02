#' @title helpers to facilitate sql executions
#'
#' @description The \code{functions run_interpolated_query} and
#' \code{run_interpolated_execution} are (sub)helper functions that establish
#' and close database connections to facilitate either a SQL query to return an
#' objet or execute a statement.
#'
#' importFrom DBI dbGetQuery dbExecute
#' importFrom shiny showNotification
#' importFrom pool poolWithTransaction
#'
#' @export
#'
run_interpolated_query <- function(interpolatedQuery) {

  tryCatch({

    queryResult <- DBI::dbGetQuery(
      # conn      = this_pool,
      conn      = connection$this_conn,
      statement = interpolatedQuery
    )

    return(queryResult)

  }, warning = function(warn) {

      shiny::showNotification(
        ui          = paste("there is a warning:  ", warn),
        duration    = NULL,
        closeButton = TRUE,
        type        = "warning"
      )

      print(paste("WARNING: ", warn))

    }, error = function(err) {

      shiny::showNotification(
        ui          = paste("there was an error:  ", err),
        duration    = NULL,
        closeButton = TRUE,
        type        = "error"
      )

      print(paste("ERROR: ", err))
      print("ROLLING BACK TRANSACTION")

    }) # close try catch

} # close run_interpolated_query


run_interpolated_execution <- function(
  interpolatedQuery,
  show_notification = FALSE
) {

  tryCatch({

    pool::poolWithTransaction(
      pool = this_pool,
      func = function(conn) {
        DBI::dbExecute(
          conn,
          interpolatedQuery
        )
      }
    )

    if (show_notification == TRUE) {

      shiny::showNotification(
        ui          = "successfully uploaded",
        duration    = NULL,
        closeButton = TRUE,
        type        = "message",
        action      = shiny::a(href = "javascript:location.reload();", "reload the page")
      )

    }

  }, warning = function(warn) {

      shiny::showNotification(
        ui          = paste("there is a warning:  ", warn),
        duration    = NULL,
        closeButton = TRUE,
        type        = "warning"
      )

      print(paste("WARNING: ", warn))

    }, error = function(err) {

      shiny::showNotification(
        ui          = paste("there was an error:  ", err),
        duration    = NULL,
        closeButton = TRUE,
        type        = "error"
      )

      print(paste("ERROR: ", err))
      print("ROLLING BACK TRANSACTION")

    }) # close try catch

} # close run_interpolated_execution
