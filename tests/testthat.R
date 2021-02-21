# Load all local files
R_DIR <- paste0(here::here(), "/R")
sapply(list.files(R_DIR, full.names = TRUE), source)

# Run all tests
library(testthat)
test_dir(paste0(here::here(), "/tests/testthat/"))
