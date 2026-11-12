# Test extract_date_range() -----------------------------------------------------
test_that("extract_date_range()", {
  f <- test_path("fixtures", "this_yr.csv.gz")
  expect_silent(r <- extract_date_range(f))
  expect_type(r, "character")
  expect_equal(r, "2025-01-01 to 2026-11-07")

  expect_silent(r <- extract_date_range(c(f, f)))
  expect_length(r, 2)
})

# Test dt_to_char() and char_to_dt() ------------------------------------------

test_that("dt_to_char() converts dates to character", {
  dates <- as.Date(c("2024-01-01", "2024-12-31"))
  result <- dt_to_char(dates)
  expect_equal(result, "2024-01-01 to 2024-12-31")
})

test_that("dt_to_char() handles single date", {
  date <- as.Date("2024-01-01")
  result <- dt_to_char(date)
  expect_equal(result, "2024-01-01")
})

test_that("char_to_dt() converts character to dates", {
  result <- char_to_dt("2024-01-01 to 2024-12-31")
  expect_s3_class(result, "Date")
  expect_equal(result, as.Date(c("2024-01-01", "2024-12-31")))
})

test_that("char_to_dt() handles single date by adding default start", {
  result <- char_to_dt("2024-12-31")
  expect_equal(result, as.Date(c("1900-01-01", "2024-12-31")))
})


# Test ask() -------------------------------------------------------------------

test_that("ask() returns TRUE in non-interactive mode", {
  # ask() should return TRUE when not interactive
  withr::local_options(list(rlang_interactive = FALSE))
  expect_true(ask("Test message", "No ask message"))
})
