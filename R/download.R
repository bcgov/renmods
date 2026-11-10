# Copyright 2026 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

#' Update cached EnMoDS data
#'
#' Downloads EnMoDS data from BC Gov and saves to the local cache.
#' By default, only missing or outdated data is downloaded.
#'
#' @param types Character. Which data types to update. One or more of
#'   "this_yr", "yr_2_5", "yr_5_10", "historic", or "all" (default "this_yr").
#' @param force Logical. If `TRUE`, downloads data even if cache is up-to-date
#'   (default `FALSE`).
#'
#' @returns `NULL` invisibly. Called for side effect of downloading data.
#'
#' @export
#' @examples
#' \dontrun{
#' # Update current year data
#' renmods_update()
#'
#' # Update all data types
#' renmods_update("all")
#'
#' # Force update of specific types
#' renmods_update(c("this_yr", "yr_2_5"), force = TRUE)
#' }

renmods_update <- function(types = "this_yr", force = FALSE) {
  types <- check_types(types)

  # Repeat for "all" if requested
  if (length(types) > 1) {
    purrr::walk(types, \(t) renmods_update(t, force = force))
    return(invisible())
  }

  # Single type from here on
  type <- types

  if (check_cache(type, force)) {
    renmods_update_(type)
  } else {
    cli_alert_success(
      "Data '{type}' already present and up-to-date (use `force = TRUE` to update anyway)"
    )
  }
}

#' Internal function to download data
#'
#' Downloads a single data type from EnMoDS and updates cache metadata.
#' This is the internal worker function called by `renmods_update()`.
#'
#' @param type Character. Single data type to download.
#'
#' @returns `NULL` invisibly. Called for side effect of downloading data.
#'
#' @noRd
#' @examples
#' \dontrun{
#'   renmods_update_("this_yr")
#' }

renmods_update_ <- function(type) {
  path <- cache_path(type)
  url <- getOption("renmods.urls")[[type]]

  cli_par()
  cli_alert("Downloading '{type}' data from ENMODS")
  cli_alert_info("Saving to cache: {path}")

  # Remove file from metadata - In case download aborted, metadata is correct
  cache_meta(types = type, reset = TRUE)

  httr2::request(url) |>
    httr2::req_progress() |>
    httr2::req_perform(path = path)

  # Record metadata
  cache_meta(types = type, update = TRUE)

  cli_alert_success("Data '{type}' successfully downloaded")
}
