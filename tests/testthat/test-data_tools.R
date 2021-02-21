context("Testing Data Tools Module")

skip_if_no_token <- function() {
    if(!googlesheets4::gs4_has_token()) {
        skip("No token")
    }
}

mock_gs_url <- "https://docs.google.com/spreadsheets/d/1uL-Oci8vavg07lfAqapcPZhS5NmRh5rhIn36wrldjY0/edit#gid=0"

test_that("load_and_save_gsheet returns expected data.frame", {
    skip_if_offline()
    skip_if_no_token()
    
    expected_df <- data.frame(
        State = c("PA", "NV"), 
        Capital = c("Harrisburg", "Carson City"), 
        Population = c(12800900, 3027340), 
        Population_string = c("12,800,900", "3,027,340")
    )
    
    res <- load_and_save_gsheet(
        url=mock_gs_url
    )
    
    expect_equal(as.data.frame(res), expected_df)
})


test_that("load_and_save_gsheet raises if given an invalid directory", {
    skip_if_offline()
    skip_if_no_token()
    
    expect_error(
        load_and_save_gsheet(
            url=mock_gs_url, 
            file_path="/definitely/not/a/valid/directory/awesome.csv"
        ), 
        regexp = "ERROR: /definitely/not/a/valid/directory not a valid directory"
    )    
})


test_that("load_and_save_gsheet raises if given an invalid file type", {
    skip_if_offline()
    skip_if_no_token()
    
    tmp_dir <- tempdir()
    
    expect_error(
        load_and_save_gsheet(
            url=mock_gs_url, 
            file_path=paste0(tmp_dir, "/awesome.txt")
        ), 
        regexp = "ERROR: only .csv files currently supported in local write operations"
    )    
})


test_that("load_and_save_gsheet does not return df if return_df=FALSE", {
    skip_if_offline()
    skip_if_no_token()
    
    tmp_dir <- tempdir()
    
    res <- load_and_save_gsheet(
        url=mock_gs_url, 
        file_path=paste0(tmp_dir, "/awesome.csv"), 
        return_df = FALSE
    )
    
    expect_true(is.null(res))
})


test_that("load_and_save_gsheet writes to csv with properly formatted file_path", {
    skip_if_offline()
    skip_if_no_token()
    
    tmp_dir <- tempdir()
    file_path <- paste0(tmp_dir, "/awesome.csv")
    
    load_and_save_gsheet(
        url=mock_gs_url, 
        file_path=file_path, 
        return_df=FALSE
    )
    
    expect_true(file.exists(file_path))
})


test_that("load_and_save_gsheet writes csv to path and retrieved csv contains expected data", {
    skip_if_offline()
    skip_if_no_token()
    
    tmp_dir <- tempdir()
    file_path <- paste0(tmp_dir, "/awesome.csv")
    
    expected_df <- data.frame(
        State = c("PA", "NV"), 
        Capital = c("Harrisburg", "Carson City"), 
        Population = c(12800900, 3027340), 
        Population_string = c("12,800,900", "3,027,340")
    )
    
    load_and_save_gsheet(
        url=mock_gs_url, 
        file_path=file_path, 
        return_df = FALSE
    )
    
    retrieved_df <- read.csv(file_path)
    
    expect_equal(retrieved_df, expected_df)
})


test_that("load_and_save_gsheet writes csv to path and returns csv when prompted", {
    skip_if_offline()
    skip_if_no_token()
    
    tmp_dir <- tempdir()
    file_path <- paste0(tmp_dir, "/awesome.csv")

    
    res <- load_and_save_gsheet(
        url=mock_gs_url, 
        file_path=file_path 
    )
    
    retrieved_df <- read.csv(file_path)
    
    expect_equal(retrieved_df, as.data.frame(res))
})