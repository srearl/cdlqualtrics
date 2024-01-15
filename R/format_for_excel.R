#' @title Format raw observation data downloaded from Qualtrics to match the
#' structure expected by the interactive Observation Query spreadsheet
#'
#' @description \code{format_for_excel} accepts as input a csv file downloaded
#' from Qualtrics from the set of observation behaviour data. The function
#' formats the data in the input file into a format expected by the interactive
#' Observation Query Excel spreadsheet that provides functionality to explore
#' the data in graphical and tabular format.
#'
#' @note \code{format_for_excel} was purposefully built with only base R
#' function so as to minimize installation overhead.
#'
#' @param qualtrics_file
#' (character) the quoted name of the csv file to format
#' @param class
#' (character) the quoted name of the class associated with the data in the
#' downloaded file in one of the prescribed formats expected by the Observation
#' Query spreadsheet.
#' @param semester
#' (character) the quoted name of the semester and year associated with data in
#' the downloaded file in one of the prescribed formats expected by the
#' Observation Query spreadsheet: (S)pring or (F)all, YY (e.g., "S23")
#'
#' @return A formatted csv file with the name `class_semester.csv`
#'
#' @examples
#' \dontrun{
#'
#' format_for_excel(
#'   qualtrics_file = "Fall 2022 CSL Observation Sheets MWF Multi-Age_October 4, 2023_07.45.csv",
#'   class          = "MWFMulti",
#'   semester       = "S23"
#' )
#'
#' }
#'
#' @export

format_for_excel <- function(
  qualtrics_file,
  class,
  semester
) {

  # check arguments

  if (missing(class)) {
    stop("you must indicate the class")
  }

  if (missing(semester)) {
    stop("you must indicate the semster")
  }

  if (!grepl("MWF|TTh|Pre", class, ignore.case = FALSE)) {
    message("that class type is unexpected please be sure it is correct")
  }

  # read data

  from_file <- read.csv(
    file   = qualtrics_file,
    header = TRUE
  )

  from_file <- from_file[-c(1, 2), ] # remove metadata rows
  from_file <- from_file[!grepl("test", from_file$Q1, ignore.case = TRUE), ] # remove test cases
  from_file <- from_file[c(grepl("recorded|response|q1|q2_|q3|q4", colnames(from_file), ignore.case = TRUE))] # pare to relevant columns

  from_file$Q32 <- gsub("[\r\n]", ".", from_file$Q32) # remove line breaks from Q32

  from_file[from_file == ""] <- NA # empty strings to NA (need to TEST that this does not alter the Excel functionality)

  # rename selected columns

  colnames(from_file)[colnames(from_file) == "RecordedDate"]   <- "Date" # rename
  colnames(from_file)[colnames(from_file) == "ResponseId"]     <- "ResponseID" # rename
  colnames(from_file)[grepl("Q31.*TEXT", colnames(from_file))] <- "Q31_TEXT" # rename

  # format date

  from_file$Date <- as.Date(from_file$Date, format = "%Y-%m-%d")
  from_file$Date <- format(from_file$Date, format = "%m/%d/%Y")

  # generate unique records for multi-child observations

  response_x_child <- reshape(
    data      = from_file[grepl("response|q2_", colnames(from_file), ignore.case = TRUE)],
    direction = "long",
    varying   = colnames(from_file)[grepl("q2_", colnames(from_file), ignore.case = TRUE)],
    v.names   = "Kid",
    idvar     = "ResponseID",
    times     = colnames(from_file)[grepl("q2_", colnames(from_file), ignore.case = TRUE)],
    timevar   = "question"
  )

  response_x_child <- response_x_child[response_x_child$Kid != "", c("ResponseID", "Kid")]

  from_file <- merge(
    x  = from_file[!(grepl("q2", colnames(from_file), ignore.case = TRUE))],
    y  = response_x_child,
    by = c("ResponseID")
  )

  # response types to numeric

  from_file$Q3[grepl("cognitive", from_file$Q3, ignore.case = TRUE)]  <- 1
  from_file$Q3[grepl("emotional", from_file$Q3, ignore.case = TRUE)]  <- 2
  from_file$Q3[grepl("prosocial", from_file$Q3, ignore.case = TRUE)]  <- 3
  from_file$Q3[grepl("anti", from_file$Q3, ignore.case = TRUE)]       <- 4
  from_file$Q3[grepl("regulation", from_file$Q3, ignore.case = TRUE)] <- 5

  from_file$Q4[grepl("problem", from_file$Q4, ignore.case = TRUE)]      <- 1
  from_file$Q4[grepl("planning", from_file$Q4, ignore.case = TRUE)]     <- 2
  from_file$Q4[grepl("persistance", from_file$Q4, ignore.case = TRUE)]  <- 3
  from_file$Q4[grepl("own", from_file$Q4, ignore.case = TRUE)]          <- 4
  from_file$Q4[grepl("others", from_file$Q4, ignore.case = TRUE)]       <- 5
  from_file$Q4[from_file$Q4 == "Verbally Expresses Empathy"]            <- 6
  from_file$Q4[from_file$Q4 == "Physical Empathy"]                      <- 7
  from_file$Q4[grepl("interactive", from_file$Q4, ignore.case = TRUE)]  <- 8
  from_file$Q4[grepl("sharing", from_file$Q4, ignore.case = TRUE)]      <- 9
  from_file$Q4[grepl("taking", from_file$Q4, ignore.case = TRUE)]       <- 10
  from_file$Q4[grepl("helpfullness", from_file$Q4, ignore.case = TRUE)] <- 11
  from_file$Q4[from_file$Q4 == "Relational Agression"]                  <- 12
  from_file$Q4[from_file$Q4 == "Verbal Aggression"]                     <- 13
  from_file$Q4[from_file$Q4 == "Instrumental Agression"]                <- 14
  from_file$Q4[from_file$Q4 == "Physical Agression"]                    <- 15
  from_file$Q4[from_file$Q4 == "Refusing to take turns"]                <- 16
  from_file$Q4[from_file$Q4 == "Not following directions"]              <- 17
  from_file$Q4[from_file$Q4 == "Verbally inappropriate"]                <- 18
  from_file$Q4[from_file$Q4 == "Distracting others"]                    <- 19
  from_file$Q4[grepl("tantrums", from_file$Q4, ignore.case = TRUE)]     <- 20
  from_file$Q4[grepl("shy", from_file$Q4, ignore.case = TRUE)]          <- 21
  from_file$Q4[grepl("loner", from_file$Q4, ignore.case = TRUE)]        <- 22

  from_file$Q30[grepl("center", from_file$Q30, ignore.case = TRUE)]     <- 1
  from_file$Q30[grepl("transition", from_file$Q30, ignore.case = TRUE)] <- 2
  from_file$Q30[grepl("outside", from_file$Q30, ignore.case = TRUE)]    <- 3
  from_file$Q30[grepl("break", from_file$Q30, ignore.case = TRUE)]      <- 4
  from_file$Q30[grepl("group", from_file$Q30, ignore.case = TRUE)]      <- 5
  from_file$Q30[grepl("special", from_file$Q30, ignore.case = TRUE)]    <- 6

  from_file$Q31[grepl("art", from_file$Q31, ignore.case = TRUE)]         <- 1
  from_file$Q31[grepl("math", from_file$Q31, ignore.case = TRUE)]        <- 2
  from_file$Q31[grepl("writing", from_file$Q31, ignore.case = TRUE)]     <- 3
  from_file$Q31[grepl("science", from_file$Q31, ignore.case = TRUE)]     <- 4
  from_file$Q31[grepl("drama", from_file$Q31, ignore.case = TRUE)]       <- 5
  from_file$Q31[grepl("floor", from_file$Q31, ignore.case = TRUE)]       <- 6
  from_file$Q31[grepl("clean", from_file$Q31, ignore.case = TRUE)]       <- 7
  from_file$Q31[grepl("outside", from_file$Q31, ignore.case = TRUE)]     <- 8
  from_file$Q31[grepl("inside", from_file$Q31, ignore.case = TRUE)]      <- 9
  from_file$Q31[grepl("small", from_file$Q31, ignore.case = TRUE)]       <- 10
  from_file$Q31[grepl("large", from_file$Q31, ignore.case = TRUE)]       <- 11
  from_file$Q31[grepl("snack", from_file$Q31, ignore.case = TRUE)]       <- 12
  from_file$Q31[grepl("lunch", from_file$Q31, ignore.case = TRUE)]       <- 13
  from_file$Q31[grepl("handwashing", from_file$Q31, ignore.case = TRUE)] <- 14
  from_file$Q31[grepl("toileting", from_file$Q31, ignore.case = TRUE)]   <- 15
  from_file$Q31[grepl("music", from_file$Q31, ignore.case = TRUE)]       <- 16
  from_file$Q31[grepl("jungle", from_file$Q31, ignore.case = TRUE)]      <- 17
  from_file$Q31[grepl("sandbox", from_file$Q31, ignore.case = TRUE)]     <- 18
  from_file$Q31[grepl("playhouses", from_file$Q31, ignore.case = TRUE)]  <- 19
  from_file$Q31[grepl("butterfly", from_file$Q31, ignore.case = TRUE)]   <- 20
  from_file$Q31[grepl("circular", from_file$Q31, ignore.case = TRUE)]    <- 21
  from_file$Q31[grepl("other", from_file$Q31, ignore.case = TRUE)]       <- 22

  # add class and semester metadata

  from_file$Class    <- class
  from_file$Semester <- semester
  from_file$Other    <- NA

  # specify column order

  from_file <- from_file[, c(
    "Class",
    "Semester",
    "Kid",
    "ResponseID",
    "Date",
    "Q1",
    "Q3",
    "Q4",
    "Other",
    "Q30",
    "Q31",
    "Q31_TEXT",
    "Q32"
  )]

  # write to file

  write.csv(
    x         = from_file,
    file      = paste0(class, "_", semester, ".csv"),
    row.names = FALSE,
    na        = ""
  )

}
