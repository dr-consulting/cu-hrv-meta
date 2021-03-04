#' Calculates standardized difference (d) between means of independent groups
#' 

calculate_d <- function(m1, m2, sd1, sd2, n1, n2, correct = FALSE, return_var = FALSE) {
    df <- n1 + n2 - 2
    mean_diff <- m1 - m2
    s_pooled <- sqrt(
        ((n1 - 1) * sd1^2 + (n2 - 1) * sd2^2) / df
    )
    
    d <- mean_diff / s_pooled
    d_var <- (n1 + n2) / (n1 * n2) + d^2 / (2 * (n1 + n2)) 
    
    # Apply Hedge's g correction and return estimate or its variance
    if(correct) {
        correction_factor <- 1 - 3 / (4 * df - 1)
        g <- d * correction_factor
        message("Correction factor applied, returning Hedge's g")
        if(return_var) {
            g_var <- correction_factor^2 * d_var
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
    if(is.na(r)) {
        return(NA)
    }
    
    else if(r < -1 | r > 1) {
        stop(
            paste0("ERROR: invalid correlation metric provided that is outside [-1, 1] boundaries")
        )
    }
    
    return(.5 * log((1 + r) / (1 - r)))
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

#' Converts d or d variance to r or r variance 
#' 

d_to_r <- function(d, n1, n2, return_var = FALSE) { 
    correction_factor <- (n1 + n2)^2 / (n1 * n2)
    d_var <- (n1 + n2) / (n1 * n2) + d^2 / (2 * (n1 + n2)) 
    if(return_var){ 
        r_var <- (correction_factor^2 * d_var) / (d^2 + correction_factor)^3
        return(r_var)
    }
    
    d / sqrt(d^2 + correction_factor)
}


#' Calculates r variance 
#' 

r_var <- function(r, n) {
    (1-r^2)^2 / (n - 1)
}


#' Estimates a HR standard deviation given mean and sd in HP units 
#' 
#' The summary stats used for the conversion must be positive (which should be the case for heart period metrics)
#' 
#' Base formula courtesy of: https://math.stackexchange.com/a/269261

estimate_hr_mean_sd <- function(hp_mean, hp_sd, hp_denom=1) {
    # This works under the assumption that x distribution is positively distributed
    # Returns in a beats per second metric - which simplifies the conversion formula slightly
    # For the purposes of this report that should be fine as we are interested in standardized effects in the end
    hp_mean <- hp_mean / hp_denom
    hp_var <- (hp_sd / hp_denom)^2
    
    hr_mean <- 1 / hp_mean + hp_var / hp_mean^3
    hr_var <- hp_var / hp_mean^4
    
    list(hr_bps_mean = hr_mean, 
         hr_bps_sd = sqrt(hr_var))
}
