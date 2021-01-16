# Utility functions for repository

#' Function for creating Python-like f-string notation throughout the repository. 
#' 

`f` <- function(x) {
    require(glue)
    initial_msg <- "Problem parsing input. Be sure you have provided a properly formatted string/character value"
    glue_msg <- "f is a wrapper around the glue() package. The glue error is pasted below:"
    out <- tryCatch(
        {
            as.character(glue::glue(x))
        }, 
        error = function(cond) {
            message(initial_msg)
            message(glue_msg)
            message(cond)
        }, 
        warning = function(cond) {
            message(initial_msg)
            message(glue_msg)
            message(cond)
        }
    )
    
    return(out)
}

#' Calculates standardized difference (d) between means of independent groups
#' 

calculate_d <- function(m1, m2, sd1, sd2, n1, n2, correct = FALSE, return_var = FALSE) {
    df <- n1 + n2 - 2
    mean_diff <- m1 - m2
    s_wthn <- sqrt(
        ((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / df
    )
    
    d <- mean_diff / s_within
    d_var <- (n1 + n2) / (n1 * n2) + d^2/(2 * (n1 + n2))
    
    # Apply Hedge's g correction and return estimate or its variance
    if(correct) {
        correction_factor <- 1 - 3 / (4 * df - 1)
        g <- d * correction_factor
        message("Correction factor applied, returning Hedge's g")
        if(return_var) {
            g_var <- correct_factor^2 * d_var
            return(g_var)
        }
        else {
            return(g)
        }
    }
    
    # Return d or d_var
    else{
        if(return_var) {
            return(d_var)
        }
        else {
            return(d)
        }
    }
}


#' Converts correlation to Fisher's z-scale 
#' 

r_to_z <- function(r) {
    .5 * log((1 + r) / (1 - r))
}

#' Coverts Fisher's z-scaled correlation back to r
#' 

z_to_r <- function(z) {
    e <- exp(1)
    (e^(2 * z) - 1) / (e^(2 * z) + 1)
}

#' Using the n that generated the original correlation calculate variance of Fisher's z-converted correlation
#' 

z_var <- function(n) {
    1 / (n - 3)
}

#' Converts d to correlation scale
#' 

d_to_r <- function(d, n1, n2) { 
    correction_factor <- (n1 + n2)^2 / (n1 * n2)
    d / sqrt(d^2 + correction_factor)
}
