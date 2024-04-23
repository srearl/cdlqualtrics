main_from_global <- "hi from global"

# configuration ----------------------------------------------------------------

this_pool <- pool::dbPool(
  drv      = RSQLite::SQLite(),
  dbname   = "/tmp/cslobsdb.db",
  shutdown = TRUE
)

DBI::dbExecute(
  conn      = this_pool,
  statement = "PRAGMA foreign_keys = ON ;"
)

shiny::onStop(function() {
  cat("closing pool from global\n")
  pool::poolClose(this_pool)
})

this_theme <- bslib::bs_theme(
  version    = 5,
  bootswatch = "zephyr"
)
