# Test check_datasets() ----------------------------------------------------------

test_that("check_datasets() works with valid datasets", {
  expect_silent(check_datasets("this_yr"))
  expect_silent(check_datasets(c("this_yr", "yr_2_5")))
  expect_silent(check_datasets("all"))
})

test_that("check_datasets() returns all datasets when 'all'", {
  result <- check_datasets("all")
  expect_named(
    setNames(result, result),
    c("this_yr", "yr_2_5", "yr_5_10", "historic"),
    ignore.order = TRUE
  )
})

test_that("check_datasets() errors with invalid datasets", {
  expect_error(check_datasets("invalid"), "`datasets` must be one of")
  expect_error(
    check_datasets(c("this_yr", "invalid")),
    "`datasets` must be one of"
  )
})


# Test check_dates() -----------------------------------------------------------

test_that("check_dates() works with valid dates", {
  expect_silent(check_dates("2024-01-01"))
  expect_silent(check_dates(as.Date("2024-01-01")))
  expect_silent(check_dates(c("2024-01-01", "2024-12-31"), range = TRUE))
})

test_that("check_dates() converts to Date class", {
  result <- check_dates("2024-01-01")
  expect_s3_class(result, "Date")
  expect_equal(result, as.Date("2024-01-01"))
})

test_that("check_dates() sorts date ranges", {
  result <- check_dates(c("2024-12-31", "2024-01-01"), range = TRUE)
  expect_equal(result, as.Date(c("2024-01-01", "2024-12-31")))
})

test_that("check_dates() errors with invalid dates", {
  expect_error(check_dates("2025-13-01"), "must be valid dates")
  expect_error(check_dates("not-a-date"), "must be valid dates")
})

test_that("check_dates() errors when range != 2 values", {
  expect_error(
    check_dates("2024-01-01", range = TRUE),
    "must have two values"
  )
  expect_error(
    check_dates(c("2024-01-01", "2024-02-01", "2024-03-01"), range = TRUE),
    "must have two values"
  )
})

test_that("check_dates() truncates datetime to date", {
  result <- check_dates("2024-01-01 12:34:56")
  expect_equal(result, as.Date("2024-01-01"))
})
