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


test_that("r_to_z returns expected values", {
    test_vals <- c(-.5, 0, .5)
    expected_vals <- c(-0.5493061443, 0, 0.5493061443)
    for(i in seq_along(test_vals)) {
        res <- r_to_z(test_vals[i])
        expect_equal(res, expected_vals[i])
    }
})


test_that("r_to_z raises if correlation is outside valid boundaries", {
    test_vals <- c(-1.2, 1.2)
    for(r in test_vals) {
        expect_error(
            r_to_z(r), 
            rregexp = "ERROR: invalid correlation metric"
        ) 
    }
})


test_that("z_to_r returns expected values", {
    test_vals <- c(-0.5493061443, 0, 0.5493061443)
    expected_vals <- c(-.5, 0, .5)
    for(i in seq_along(test_vals)) {
        res <- z_to_r(test_vals[i])
        expect_equal(res, expected_vals[i])
    }
})


test_that("d_to_r returns correct r value", {
    res <- d_to_r(d=1.154700538, n1=40, n2=40)
    expected <- .5
    expect_equal(res, expected)
})


test_that("d_to_r returns correct r variance when requested value", {
    res <- d_to_r(d=1.154700538, n1=40, n2=40, return_var = TRUE)
    expected <- 0.006152344
    expect_equal(res, expected)
})
