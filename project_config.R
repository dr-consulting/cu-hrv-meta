# top-level file that should be executed by most compute scripts
ROOT_DIR <- "~/github/BASE_lab/cu-hrv-meta" 

# URL for most up-to-date inputs file
GSHEET_URL <- "https://docs.google.com/spreadsheets/d/15ekVKHpztq-IfvOBC4HM1IWdEllHpYTY/edit#gid=120090311"

# bringing local utility functions
source(paste0(ROOT_DIR, '/R/utils.R'))

# Add global structure to repo
DATA_DIR <- f("{ROOT_DIR}/data")
TEST_DIR <- f("{ROOT_DIR}/tests")
OUTPUT_DIR <- f("{ROOT_DIR}/output")
R_SRC <- f("{ROOT_DIR}/R")
RAW_INPUTS_FILENAME <- "data_extraction_v3_2021-01-05.csv"

raw_inputs <- read.csv(f("{DATA_DIR}/{RAW_INPUTS_FILENAME}"))
