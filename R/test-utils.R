# For test mocking of base functions
file.exists <- NULL

#' Skip test if no cache directory exists
#'
#' Checks for cache directory and cached data. Skips test if either is missing.
#' This is a test helper function for use in testthat tests.
#'
#' @returns `NULL`. Called for side effect of skipping tests.
#'
#' @noRd
#' @examples
#' test_that("function works with cache", {
#'   skip_if_no_cache()
#'   # test code here
#' })

skip_if_no_cache <- function() {
  if (!cache_dir(check_only = TRUE)) {
    testthat::skip("No cache directory exists")
  }

  status <- cache_status()
  has_data <- all(!is.na(status$path) & file.exists(status$path))

  if (!has_data) {
    testthat::skip(
      "No cached data available. Run renmods_update() to download data."
    )
  }
}

#' Skip test if specific data type not cached
#'
#' Checks for cached data of a specific type. Skips test if not available.
#' This is a test helper function for use in testthat tests.
#'
#' @param type Character. Data type to check for.
#'
#' @returns `NULL`. Called for side effect of skipping tests.
#'
#' @noRd
#' @examples
#' test_that("function works with this_yr data", {
#'   skip_if_no_type("this_yr")
#'   # test code here
#' })

skip_if_no_type <- function(type) {
  skip_if_no_cache()

  path <- cache_path(type)
  if (!file.exists(path)) {
    testthat::skip(paste0(
      "No cached data for type '",
      type,
      "'. Run renmods_update('",
      type,
      "')"
    ))
  }
}

skip_on_local <- function() {
  testthat::skip_if(!isTRUE(as.logical(Sys.getenv("CI", "false"))), "Not on CI")
}

expect_rows <- function(db) {
  n <- db |> utils::head(1) |> collect() |> nrow()
  testthat::expect_gt(n, 0)
}
