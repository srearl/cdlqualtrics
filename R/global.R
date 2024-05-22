# configuration ----------------------------------------------------------------

options(shiny.error = browser)

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

# behaviour levels, colors for output$behaviour_view ---------------------------

behaviour_type_colors <- c(
  "Aggression"              = "#67001F",
  "Cognitive"               = "#AA9486",
  "Emotional"               = "#B6854D",
  "Inappropriate Behaviors" = "#EAD3BF",
  "Prosocial"               = "#39312F"
)

behaviour_levels <- c(
  "Instrumental Agression",
  "Physical Agression",
  "Relational Agression",
  "Verbal Aggression",
  "Persistance",
  "Planning",
  "Problem Solving",
  "Physical Empathy",
  "Verbally Expresses Empathy",
  "Verbally Expresses Others' Emotions",
  "Verbally Expresses Own Emotions",
  "Crying / tantrums / fits",
  "Distracting others",
  "Loner",
  "Not following directions",
  "Refusing to take turns",
  "Shy",
  "Verbally inappropriate",
  "Helpfullness",
  "Interactive Play",
  "Sharing",
  "Turn taking"
)
