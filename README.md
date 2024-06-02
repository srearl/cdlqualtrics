## cslqualtrics

**R-based tools to manage a database of Qualtrics behaviour observation data and interact with stored data**


### overview

Presented here is an R-based tool to format data collected in Qualtrics so as to be compatible with the data structure expected by a Observation Query Excel spreadsheet that is used to visualize patterns in the observation data. The formatting function requires as inputs the name of the file, along with the year and semester associated with the observation data. The output is a tabular csv file appropriately named with the class type, year, and semester in the working directory and of a format in keeping with existing data. The formatted file can then be transferred to a directory holding files from other classes, semesters that have similar formatting that are sourced by the Observation Query Excel spreadsheet.


### installation

An installation of R and several libraries are required. The following steps need to be run only once on any given computer.

1. The easiest way to interface with R, particularly on machines running Windows, is through the RStudio IDE. Instructions for installing R and RStudio are available through [Posit](https://posit.co/download/rstudio-desktop/), or they can be accessed through the [ASU software center](https://ets.engineering.asu.edu/softwareage/software/). 

2. Once R and RStudio are installed, install the `remotes` library to facilitate installing the cslqualtrics library to format the Qualtrics data.

![](inst/image/rstudio_install_remotes.png)
*Install the `remotes` library by issuing the command `install.packages("remotes")` in the RStudio interface.*

3. Use the `remotes` library to install the cslqualtrics library from GitHub.

![](inst/image/rstudio_install_qualtrics.png)
*Install the `cslqualtrics` library by issuing the command `remotes::install_github("srearl/cslqualtrics")` in the RStudio interface.*

4. Depending on the R installation, it may be necessary to install additional libraries. Additional libraries that may need to be installed include `bslib`, `DBI`, `dplyr`, `DT`, `glue`, `janitor`, `pool`, `qualtRics`, `RSQLite`, `shiny`, `stringr`, `tidyr`, and `tidyselect`. As needed, install these packages with the `Packages` > `Install` tool within RStudio or by issuing a command similar to `r install.packages(c("bslib", "DBI", "dplyr", "DT", "glue", "janitor", "pool", "qualtRics", "RSQLite", "shiny", "stringr", "tidyr", "tidyselect")` in the R console.

### configuration

Survey data are housed in an Sqlite database. A Qualtrics API key is required to refresh the datbaase with new or updated data entered into Qualtrics. 



### application

#### launch the application

#### load the database

#### update surveys and observations

#### view data


### metadata

#### questions

| question | meaning                            |
|:---------|:-----------------------------------|
| Q1       | TA identifier                      |
| Q5       | agressed against                   |
| Q30      | context (e.g., 'center time')      |
| Q31      | activity (e.g., 'art'); location   |

#### Qualtrics survey dates [explained](https://kb.ndsu.edu/page.php?id=128266):

- StartDate: These date and time values indicate when the respondents first clicked the survey link.
- EndDate: These date and time values indicate when the respondent submitted their survey. If the entry is an incomplete response, this date will indicate the last time the respondent interacted with the survey.
- RecordedDate: This column indicates when a survey was recorded in Qualtrics.

Because of incomplete responses, the EndDate and RecordedDate may disagree. The difference can be determined by the time you select for incomplete responses, or by the default of seven days.


### design considerations

#### database connection

That the user has to identify the path and filename of the target database requires that establishign a connection to the database be addressed via the application. This is quite unlike a more typical approach of establishing a globally scoped database connection when the application is started sensu below:

typical approach to establishing a database connection, usually in `global.R`:

```r
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
  cat(con$cc)
  cat("closing pool from global\n")
  # pool::poolClose(this_pool)
  pool::poolClose(con$cc)
})
```

Rather, the database connection is established by the user and held in a globally scoped (via `<--`) `shiny::reactiveValues` object created in `server.R`.

This also complicates closing/returning the database connection, which is a `pool::pool` object. Closing the pool is addressed by forcing the application to stop (via `shiny::stopApp`) when the session is ended (`session$onSessionEnded...`). While this approach is generally considered a bad practice because it closes the application for all users when any given session is terminated, it is expected that only one user would interact with the application at any given time.
