#' Plot effects of Bayesian meta-analysis
#' 

plot_bayes_forest <- function(model, study_id, title, xlab, ylab, interval = .95, caption=NULL) {
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
    
    plot <- forest_df %>% 
        ggplot(aes_string(y = study_id, x='b_Intercept')) +
        stat_halfeye() +
        scale_fill_manual(values=c('grey80', '#5b9eef')) +
        geom_text(data = mutate_if(forest_summary, is.numeric, round, 2),
                  aes(label = glue::glue("{b_Intercept} [{.lower}, {.upper}]"), x = Inf), hjust = "inward") + 
        labs(title = title, x = xlab, y = ylab, caption = caption) +
        scale_y_discrete(limits=rev) +
        theme_bw()
    
    return(plot)
}
