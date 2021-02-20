context("Testing Utility Functions")
# Tests for meta-analysis utility functions

# Values taken from worked example in Bornstein et al., 2009, pp. 22 - 28
calculate_d_params <- list(m1 = 103, m2 = 100, sd1 = 5.5, sd2 = 4.5, n1 = 50, n2 = 50)

test_that("calculate_d returns correct standardized d value for independent means", {
    res <- do.call(calculate_d, calculate_d_params)
    expected <- .5970223
    expect_equal(res, expected)
})


test_that("calculate_d returns correct d_var when prompted", {
    res <- do.call(calculate_d, c(calculate_d_params, return_var=TRUE))
    expected <- .04178218
    expect_equal(res, expected)
})


test_that("calculate_d returns correct Hedge's g value for independent means", {
    res <- do.call(calculate_d, c(calculate_d_params, correct = TRUE))
    expected <- .5924415803
    expect_equal(res, expected)
})


test_that("calculate_d prints message when requesting Hedge's g value for independent means", {
    expect_message(
        do.call(calculate_d, c(calculate_d_params, correct = TRUE)), 
        regexp = "Correction factor applied, returning Hedge's g"
    ) 
})


test_that("calculate_d returns correct Hedge's g variance for independent means", {
    res <- do.call(calculate_d, c(calculate_d_params, correct = TRUE, return_var = TRUE))
    expected <- .04114347916
    expect_equal(res, expected)
})
