# configuration ----------------------------------------------------------------

options(shiny.error = browser)

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

# qualtrics fetch survey expected columns after pivot --------------------------

observation_expected_cols <- c(
  "survey_id",
  "start_date",
  "end_date",
  "status",
  "ip_address",
  "progress",
  "duration_in_seconds",
  "finished",
  "recorded_date",
  "response_id",
  "recipient_last_name",
  "recipient_first_name",
  "recipient_email",
  "external_reference",
  "location_latitude",
  "location_longitude",
  "distribution_channel",
  "user_language",
  "question",
  "response"            
)
