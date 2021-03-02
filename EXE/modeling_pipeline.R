# Load all R local files
library(tidyverse)
library(brms)
library(brmstools)

R_DIR <- paste0(here::here(), "/R")
sapply(list.files(R_DIR, full.names = TRUE), source)
`%notin%` <- Negate(`%in%`)

gsheet_url <- "https://docs.google.com/spreadsheets/d/17-ORYryysIIL5eUjXUvrNHx2tKX5ByhasOrhw6JDpaY/edit#gid=0"

# a simple means of excluding problematic studies during pipeline execution: 
exclude_list <- c("de Wied et at., 2012")

# Load raw_data
raw_df <- load_and_save_gsheet(gsheet_url, missing_val = "NA") %>% 
    lapply(., unlist) %>% 
    as.data.frame() %>% 
    filter(citation %notin% exclude_list)

# Expected dimensions - allows me to be alerted if this changes for some reason upstream
testthat::expect_is(raw_df, "data.frame")
testthat::expect_equal(dim(raw_df), c(114, 43))

# Targeting correlations as the "base effect"
# Note some missing values now - will let the model remove for the time being...
r_eff <- raw_df[["r_cuXoutcome"]]
r_eff_var <- r_var(r_eff, raw_df[["N"]])
r_eff_se <- sqrt(r_eff_var)

d_vals <- calculate_d(
    m1 = raw_df[["Cugrp_outcome_mean"]], 
    m2 = raw_df[["ctrl_outcome_mean"]], 
    sd1 = raw_df[["Cugrp_outcome_SD"]], 
    sd2 = raw_df[["ctrl_outcome_SD"]], 
    n1 = raw_df[["N_CUgrp"]], 
    n2 = raw_df[["N_CTRLgrp"]]
)

r_eff_from_d <- d_to_r(
    d_vals, 
    n1 = raw_df[["N_CUgrp"]], 
    n2 =raw_df[["N_CTRLgrp"]]
)

r_eff_var_from_d <- d_to_r(
    d_vals, 
    n1 = raw_df[["N_CUgrp"]], 
    n2 =raw_df[["N_CTRLgrp"]], 
    return_var = TRUE
)

r_eff_se_from_d <- sqrt(r_eff_var_from_d)

R_EFFECT <- ifelse(is.na(r_eff), r_eff_from_d, r_eff)
R_SE <- ifelse(is.na(r_eff_se), r_eff_se_from_d, r_eff_se)

base_df <- data.frame(
    cite = raw_df[["citation"]], 
    cite_id = raw_df[["Id"]],
    effect_size = R_EFFECT,
    effect_se = R_SE, 
    baseline_status = raw_df[["Baseline...0..Task...1..Reactivity...2"]],
    outcome_system = raw_df[["Outcome_system"]]
)

# Getting the base effect for a few different effects
# looking first at PNS/Baseline Only

base_model <- "effect_size | se(effect_se) ~ 1 + (1|cite_id)" %>% bf()
base_priors <- c(
    prior(normal(0, 1), class = Intercept), 
    prior(cauchy(0, .5), class = sd)
)

model_PNS_baseline <- brm(
    effect_size | se(effect_se) ~ 1 + (1|cite_id), 
    prior = base_priors, 
    data = base_df %>% 
        filter(baseline_status == 0 & outcome_system == "PNS"), 
    iter = 7500,
    warmup = 5000, 
    cores = 3, 
    chains = 3, 
    control = list(adapt_delta = .99)
)

PNS_baseline_forest <- forest(model_PNS_baseline) + 
    ggtitle("CU Traits Correlations with Baseline PNS") +
    geom_vline(xintercept = 0, lty="dashed")


model_ANS_baseline <- brm(
    effect_size | se(effect_se) ~ 1 + (1|cite_id), 
    prior = base_priors, 
    data = base_df %>% 
        filter(baseline_status == 0 & outcome_system == "ANS"), 
    iter = 7500,
    warmup = 5000, 
    cores = 3, 
    chains = 3, 
    control = list(adapt_delta = .99)
)

ANS_baseline_forest <- forest(model_ANS_baseline) + 
    ggtitle("CU Traits Correlations with Baseline ANS") +
    geom_vline(xintercept = 0, lty="dashed")


model_SNS_baseline <- brm(
    effect_size | se(effect_se) ~ 1 + (1|cite_id), 
    prior = base_priors, 
    data = base_df %>% 
        filter(baseline_status == 0 & outcome_system == "SNS"), 
    iter = 7500,
    warmup = 5000, 
    cores = 3, 
    chains = 3, 
    control = list(adapt_delta = .99)
)

SNS_baseline_forest <- forest(model_SNS_baseline) + 
    ggtitle("CU Traits Correlations with Baseline SNS") +
    geom_vline(xintercept = 0, lty="dashed")

png(filename = "./output/plots/EDA_baseline_models_partial_entry.png", 
    res = 600, 
    units = "in", 
    height = 11, 
    width = 8)
cowplot::plot_grid(
    ANS_baseline_forest + scale_x_continuous(limits = c(-.6, .6)),
    PNS_baseline_forest + scale_x_continuous(limits = c(-.6, .6)), 
    SNS_baseline_forest + scale_x_continuous(limits = c(-.6, .6)), 
    ncol = 1, 
    rel_heights = c(1.5, 1, .5)
)
dev.off()