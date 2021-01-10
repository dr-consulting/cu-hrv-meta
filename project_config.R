# top-level file that should be executed by most compute scripts

library(glue)
library(tidyverse)

ROOT_DIR <- "~/github/BASE_lab/cu-hrv-meta" 
DATA_DIR <- "{ROOT_DIR}/data" %>% glue()
TEST_DIR <- "{ROOT_DIR}/tests" %>% glue()
OUTPUT_DIR <- "{ROOT_DIR}/output" %>% glue()
R_SRC <- "{ROOT_DIR}/R" %>% glue()

