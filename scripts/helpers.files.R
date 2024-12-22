library(tidyverse)
library(here)

#' Write Data Frames to CSV Files
#'
#' This function writes a list of data frames from the global environment to CSV files
#' in a specified folder. The filenames are derived from the names of the data frames.
#'
#' @param df_names A character vector of data frame names (as strings) to write as CSV files.
#' @param folder A character string specifying the folder where the CSV files will be saved.
#'   Defaults to `here("data")`.
#'
#' @return A character vector of the file paths for the created CSV files.
#' @examples
#' # Example data frames in the global environment
#' df1 <- data.frame(x = 1:3, y = c("A", "B", "C"))
#' df2 <- data.frame(a = 4:6, b = c("D", "E", "F"))
#'
#' # List of data frame names
#' df_names <- c("df1", "df2")
#'
#' # Write the data frames to the "data" folder
#' write_dfs_to_csv(df_names, folder = "data")
#'
#' # The CSV files "df1.csv" and "df2.csv" will be created in the "data" folder.
#'
#' @note The function assumes that the data frames are available in the global environment.
#'   If this is not the case, use a different environment in the `get` function.
#'
#' @export
write_dfs_to_csv <- function(df_names, folder = here("data")) {
  # Ensure the folder exists
  if (!dir.exists(folder)) {
    dir.create(folder, recursive = TRUE)
  }
  
  # Loop through the data frame names and save as CSV
  for (name in df_names) {
    # Retrieve the data frame object by name
    df <- get(name, envir = .GlobalEnv)
    
    # Construct the file path
    file_path <- file.path(folder, paste0(name, ".csv"))
    
    # Write the data frame to CSV
    write.csv(df, file = file_path, row.names = FALSE)
  }
  
  # Return a message or list of file paths
  cat("Data frames written to:", folder, "\n")
  return(file.path(folder, paste0(df_names, ".csv")))
}

#' Read CSV Files into Variables
#'
#' This function reads CSV files from a specified folder and assigns them to variables
#' in the global environment. The filenames are derived from a vector of variable names
#' by appending the `.csv` suffix.
#'
#' @param variable_names A character vector of variable names. Each name will correspond
#'   to a CSV file and the variable name created in the global environment.
#' @param folder A character string specifying the folder where the CSV files are located.
#'   Default is `"data"`.
#'
#' @return A character vector of the created variable names.
#' @examples
#' # Assume the folder "data" contains the files "ocd.values.csv" and "ocd.fears.csv"
#' variable_names <- c("ocd.values", "ocd.fears")
#' 
#' # Read the CSV files and assign them to variables
#' read_dfs_from_csv(variable_names, folder = "data")
#'
#' # Access the created variables
#' print(ocd.values)
#' print(ocd.fears)
#'
#' @note The function assigns variables to the global environment (`.GlobalEnv`).
#'   If this is not desirable, modify the `assign` function to specify a different
#'   environment.
#'
#' @export
read_dfs_from_csv <- function(variable_names, folder = here("data")) {
  # Construct file paths by appending ".csv" to variable names
  file_paths <- file.path(folder, paste0(variable_names, ".csv"))
  
  # Read each CSV and assign to the corresponding variable
  for (i in seq_along(file_paths)) {
    # Read the CSV file
    df <- read_csv(file_paths[i])
    
    # Assign the data frame to the variable name
    assign(variable_names[i], df, envir = .GlobalEnv)
  }
  
  # Return the names of the created variables
  return(variable_names)
}
