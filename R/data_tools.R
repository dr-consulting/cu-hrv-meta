# Module that contains utilities for loading and cleaning data

#' Function loads raw data from Googlesheets, and saves the file if file_name/dir_name provided
#' 
#' The function is set to load the data into memory by default. If a full valid path is provided to file_name, the 
#' function will save a .csv file in the specified location. If a file_name and a valid dir_name are provided the 
#' function will save a .csv file using the file_name in the specified directory. 
#' 
#' @param url the Googlesheet url. Will require user to enable tidyverse API access. Up to the user as to whether they 
#' want to store their credentials when prompted. 
#' 
#' @param file_path full file_path for saving the data set when downloaded. Should end in .csv. If NULL (default), the
#' Googlesheet is downloaded, but nothing will be saved
#' 
#' @param return_df if TRUE (default) the loaded Googlesheet is returned to the user as data.frame in their R session.
#' 
load_and_save_gsheet <- function(url, missing_val="NA", file_path=NULL, return_df=TRUE) {
    gsheet_df <- googlesheets4::read_sheet(url, na=missing_val)
    
    if(!is.null(file_path)) {
        dir_name <- dirname(file_path)
        
        if(!dir.exists(dir_name)) {
            stop(
                paste0("ERROR: ", dir_name, " not a valid directory")
            )
        }

        if(!tools::file_ext(file_path) == "csv") {
            stop(
                "ERROR: only .csv files currently supported in local write operations"
            )
        }
        else{
            write.csv(gsheet_df, file = file_path, row.names = FALSE)
        }
    }
    
    if(return_df) {
        return(gsheet_df)
    }
}
