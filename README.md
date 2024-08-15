## cslqualtrics

**R-based tools to manage a database of Qualtrics behaviour observation data and interact with stored data**


### overview

Presented here is an R-based tool to visualize CSL observation data. Data are stored in a local Sqlite database, and updated as appropriate via calls to the Qulatrics API, the survey instrument.

### installation

An installation of R and several libraries are required. The following steps need to be run only once on any given computer.

1. The easiest way to interface with R, particularly on machines running Windows, is through the RStudio IDE. Instructions for installing R and RStudio are available through [Posit](https://posit.co/download/rstudio-desktop/), or they can be accessed through the [ASU software center](https://ets.engineering.asu.edu/softwareage/software/). 

2. Once R and RStudio are installed, install the `remotes` library to facilitate installing the cslqualtrics library to format the Qualtrics data.

![](inst/image/rstudio_install_remotes.png)
*Install the `remotes` library by issuing the command `install.packages("remotes")` in the RStudio interface.*

3. Use the `remotes` library to install the cslqualtrics library from GitHub.

![](inst/image/rstudio_install_qualtrics.png)
*Install the `cslqualtrics` library by issuing the command `remotes::install_github("srearl/cslqualtrics")` in the RStudio interface.*

4. Depending on the R installation, it may be necessary to install additional libraries. Additional libraries that may need to be installed include `usethis`, `ggplot2`, `bslib`, `DBI`, `dplyr`, `DT`, `glue`, `janitor`, `pool`, `qualtRics`, `RSQLite`, `shiny`, `stringr`, `tidyr`, and `tidyselect`. As needed, install these packages with the `Packages` > `Install` tool within RStudio or by issuing a command similar to `r install.packages(c("usthis", "ggplot2", "bslib", "DBI", "dplyr", "DT", "glue", "janitor", "pool", "qualtRics", "RSQLite", "shiny", "stringr", "tidyr", "tidyselect"))` in the R console.

### configuration

Survey data are housed in a Sqlite database that is a local file on the user's computer. A Qualtrics API key is required to refresh the database with new or updated data entered into Qualtrics. The easiest way to interact with Qualtrics is to add the Qualtrics API key to the user's `.Renviron` file. Within R, enter `usethis::edit_r_environ()` in the console, which will open the local `.Renviron` file for editing. Add the following lines, replacing `'xxxxxx'` with the appropriate key and url, respectively, then save the file.

```r
QUALTRICS_API_KEY = 'xxxxxx'
QUALTRICS_BASE_URL = 'xxxxxx'
```

### application

#### launch the application

To launch the application, run `cslqualtrics::pkgapp()` in an R console. The application will launch (likely) in a RStudio browser; however, this is not the best viewing environment so open the application in a browser by pressing the `Open in Browser` button of the RStudio viewer, which will open the application in the default browser of the user's computer. The application was developed and tested using Firefox but any modern browser should be sufficient for interfacing with the application.

**developer note** for prototyping during development, reload and launch the app via

```r
devtools::load_all()
cslqualtrics::pkgapp()
```

#### navigation

The application consists of two suites of functionality in two top-level tabs: (1) *utilities* to connect to and manage (update) the database, and (2) *explore data* to explore observation data.

##### utilities

This tab features tools that allow the user to connect to the Sqlite database, and update survey and observation data.

###### connect the database

Survey data are housed in a local (to the user) Sqlite database that must be connected to the application. All functionality requires first connecting the application to the database. Enter the full path and name of the database in the `full path to database` dialogue box. In a Windows environment, the easiest way to get the full path and name of the database is to navigate to the directory housing the Sqlite database file using Windows explorer, right-clicking on the file, and selecting the option to `Copy as path`. The path will be something along the lines of `"C:\Users\user_name\cslobsdb.db"` - paste the full path and name but being sure to *remove the quotation marks* into the dialogue box. Once entered, connect the application to the identified file with the `load database` button. If successful, a short message indicating "connected" will display.

###### update surveys and observations

The database reflects and corresponds to two layers of Qualtrics data: surveys and observations. Surveys are data reflecting unique combinations of the year, semester, class, and reliability. Within the SURVEYS sub-panel, the `check for updates` button will query both Qualtrics and the survey data in the database to identify when there are new or updated (for example, when a student is added to an existing survey) survey data in Qualtrics but not in the database. In that case, a table providing details of survey data that are either new or updated in Qualtrics (relative to the database) will be displayed. The `add updates` button will download the new and/or updated survey data from Qualtrics and load them into the database.

Whereas *surveys* data are at the level of a class, *observations* data are behaviour and otherwise data data specific to a unique survey. Observations data associated with new or updated surveys are added to or updated in the database when updating survey data as outlined above. However, observation data (in Qualtrics) may be updated without a corresponding update to a survey. In this case, observation data, typically for the current year and semester, can be updated by specifying the year and semester to update in the OBSERVATIONS sub-panel then clicking the `update observations` button. Only observation data associated with the identified year and semester are updated.

##### explore data

Features in this tab allow the user to explore survey and observation data stored in the database. The `load data` button will display surveys data in the database, filterable by semester, year, class, etc. Clicking on a row in the table of surveys data will query observations data associated with that survey. Once a survey has been selected, a drop-down menu of students in that class is populated in the *students* sub-menu. The behaviour patterns of a selected student are viewable by toggling the *behaviour by student* panel. Whereas the *behaviour by student* panel illustrates behaviour for an individual student, the other panels (*behaviour by activity (location)* and *behaviour by TA*) display data aggregated at the class level for a breakdown of the locations where behaviours are observed and a summary of the behaviours logged by individual TAs, respectively.

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

That the user has to identify the path and filename of the target database requires that establishing a database connection is addressed via the application. This is quite unlike a more typical approach of establishing a globally scoped database connection when the application is started sensu below:

*typical approach to establishing a database connection, usually in `global.R`*:

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

Rather, the database connection is established by the user and held in a globally scoped (via `<<-`) `shiny::reactiveValues` object created in `server.R`.

This also complicates closing/returning the database connection, which is a `pool::pool` object. Closing the pool is addressed by forcing the application to stop (via `shiny::stopApp`) when the session is ended (`session$onSessionEnded...`). While this approach is generally considered a bad practice because it closes the application for all users when any given session is terminated, it is expected that only one user would interact with the application at any given time.
