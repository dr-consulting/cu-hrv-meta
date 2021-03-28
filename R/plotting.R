#' Plot effects of Bayesian meta-analysis
#' 
#' Intended to work with a intercept-only meta-analytic model. The function returns a forest plot with the random or 
#' study-level posterior distributions, posterior means and their credibility intervals (can be set by the user, default 
#' is 95%) along with the model-estimated pooled or population level distribution and accompanying summary stats. 
#' 
#' @param model \code{brms.fit} object containing the model fit for an intercept-only meta-analysis (i.e., a 
#' variance-known multilevel model). 
#' 
#' @param study_id the grouping column in the data used to track the study/citation containing the effect of interest.
#' 
#' @param title a plot title that conforms to ggplot's format
#' 
#' @param xlab a label for the x-axis - which represents the posterior distributions on the scale of the effect size
#' analyzed in the model (e.g., Fisher's z, Pearson's r, Cohen's d, etc.)
#' 
#' @param ylab a label for the y-axis - which represents the clustering unit (typically the study or citation 
#' associated with the effect). 
#' 
#' @param x_limits a vector of the form c(min, max) that specifies the upper and lower boundary of the x-axis displayed.
#' The parameter is useful when stacking plots on top of one another as it can aid in aligning axes and ease visual 
#' comparisons
#' 
#' @param interval the width of the credibility interval to be used in generating the plot and summary statistics. The
#' default value is .95 for a 95% credibility interval. 
#' 
#' @param caption (optional) a caption conforming to ggplot's format that can be displayed at the bottom of the plot 
#' area. 
#' 
#' @param fill_color a color conforming to ggplot's format for plot aesthetics that will be used to create a vertical 
#' shaded region that aligns with the pooled effect's credibility interval. 
#' 
#' @param fill_opacity a decimal ranging from 0 to 1 that controls the degree of transparency in the fill region (see 
#' above). A value of 0 indicates complete transparency a value of 1 indicates no transparency.

plot_bayes_forest <- function(model, study_id, title, xlab, ylab, x_limits, interval = .95, caption=NULL, 
                              fill_color = "#5b9eef", fill_opacity = .15) {
    require(tidybayes)
    require(dplyr)
    require(ggplot2)
    require(glue)
    require(stringr)
    study_key <- 'r_{study_id}' %>% glue::glue()
    study_draws <- spread_draws(model, (!!sym(study_key))[(!!sym(study_id)), ], b_Intercept) %>% 
        mutate(
            b_Intercept = !!sym(study_key) + b_Intercept
        )
    
    study_summary <- study_draws %>% 
        ungroup() %>% 
        group_by(!!sym(study_id)) %>% 
        mean_qi(b_Intercept, .width = interval) %>% 
        arrange(desc(b_Intercept))
    
    pooled_effect_draws <- spread_draws(model, b_Intercept)
    pooled_effect_draws[[study_id]] <- 'Pooled Effect'
    
    pooled_effect_summary <- pooled_effect_draws %>% 
        mean_qi(b_Intercept, .width = interval)
    pooled_effect_summary[[study_id]] <- 'Pooled Effect'
    
    forest_draws <- bind_rows(study_draws, pooled_effect_draws) %>% 
        ungroup()
        
    forest_summary <- bind_rows(study_summary, pooled_effect_summary)
    
    forest_df <- forest_summary %>% 
        mutate(
            mu_Intercept = b_Intercept, 
            order_ind = 1:nrow(.)
        ) %>% 
        select(all_of(c(study_id, 'mu_Intercept', '.lower', '.upper', 'order_ind'))) %>% 
        left_join(forest_draws)
    
    forest_df[[study_id]] <- str_replace_all(forest_df[[study_id]], '[.]', ' ')
    forest_df[[study_id]] <- reorder(forest_df[[study_id]], forest_df[['order_ind']])
    forest_summary[[study_id]] <- str_replace_all(forest_summary[[study_id]], '[.]', ' ')
    forest_summary[[study_id]] <- reorder(forest_summary[[study_id]], 1:nrow(forest_summary))
    
    forest_df[['fill_flag']] <- between(forest_df[['b_Intercept']], 
                                        pooled_effect_summary[['.lower']], 
                                        pooled_effect_summary[['.upper']]) %>% as.numeric()
    
    plt <- forest_df %>% 
        ggplot(aes_string(y = study_id, x='b_Intercept')) +
        stat_halfeye() +
        geom_text(data = mutate_if(forest_summary, is.numeric, round, 2),
                  aes(label = glue::glue("{b_Intercept} [{.lower}, {.upper}]"), x = Inf), hjust = "inward") + 
        labs(title = title, x = xlab, y = ylab, caption = caption) +
        scale_y_discrete(limits=rev) +
        coord_cartesian(xlim = x_limits) +
        geom_vline(xintercept = pooled_effect_summary[['.lower']], lty='dotted') +
        geom_vline(xintercept = pooled_effect_summary[['.upper']], lty='dotted') +
        geom_vline(xintercept = 0, lty='dashed') +
        geom_rect(data = data.frame(x1 = pooled_effect_summary[['.lower']], 
                                    x2 = pooled_effect_summary[['.upper']], 
                                    y1 = -Inf, 
                                    y2 = Inf), 
                  aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2),
                  alpha = fill_opacity, 
                  fill = fill_color, 
                  color = fill_color, 
                  inherit.aes = FALSE) +
        theme_bw()
    
    return(plt)
}
