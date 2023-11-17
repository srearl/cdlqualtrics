## cdlqualtrics

*R-based tools to format Qualtrics behaviour observation data*

### overview

Presented here is an R-based tool to format data collected in Qualtrics so as to be compatible with the data structure expected by a Observation Query Excel spreadsheet that is used to visualize patterns in the observation data. The formatting function requires as inputs the name of the file, along with the year and semester associated with the observation data. The output is a tabular csv file appropriately named with the class type, year, and semester in the working directory and of a format in keeping with existing data. The formatted file can then be transferred to a directory holding files from other classes, semesters that have similar formatting that are sourced by the Observation Query Excel spreadsheet.

### installation

An installation of R is required. The easiest way to interface with R, particularly on machines running Windows, is through the RStudio IDE. Instructions for installing R and RStudio are available through [Posit](https://posit.co/download/rstudio-desktop/), or they can be accessed through the [ASU software center](https://ets.engineering.asu.edu/softwareage/software/). Once installed, the `remotes` library will facilitate installing the tools to format the Qualtrics data.

![](inst/image/rstudio_install_remotes.png)
<figcaption>Install the `remotes` library by issuing the command `install.packages("remotes") in the RStudio interface.</figcaption>

![](inst/image/rstudio_directory_naviation.png)
