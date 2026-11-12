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
#' @param datasets Character. Which datasets to update. One or more of
#'   "this_yr", "yr_2_5", "yr_5_10", "historic", or "all" (default "this_yr").
#' @param force Logical. If `TRUE`, downloads data even if cache is up-to-date
#'   (default `FALSE`).
#' @param cleanup Logical. Whether to remove the downloaded `csv.gz` file(s)
#'   after conversion to parquet. Defaults to TRUE.
#' @param types Character. Deprecated, use `datasets` instead.
#'
#' @returns `NULL` invisibly. Called for side effect of downloading data.
#'
#' @export
#' @examples
#' \dontrun{
#' # Update current year data
#' renmods_update()
#'
#' # Update all datasets
#' renmods_update("all")
#'
#' # Force update of specific datasets
#' renmods_update(c("this_yr", "yr_2_5"), force = TRUE)
#' }

renmods_update <- function(
  datasets = "this_yr",
  force = FALSE,
  cleanup = TRUE,
  types = NULL
) {
  if (!missing(types)) {
    cli_alert("{.arg types} has been deprecated, use {.arg dataset} instead")
    datasets <- types
  }

  datasets <- check_datasets(datasets)

  # Repeat for "all" if requested
  if (length(datasets) > 1) {
    purrr::walk(datasets, \(t) {
      renmods_update(t, force = force, cleanup = cleanup)
    })
    return(invisible())
  }

  # Single dataset from here on
  dataset <- datasets

  if (check_cache(dataset, force)) {
    renmods_update_(dataset, cleanup)
  } else {
    cli_alert_info(
      "Data '{dataset}' already present and up-to-date (use `force = TRUE` to update anyway)"
    )
  }
}

#' Internal function to download data
#'
#' Downloads a single dataset from EnMoDS and updates cache metadata.
#' This is the internal worker function called by `renmods_update()`.
#'
#' @param dataset Character. Single dataset to download.
#' @param cleanup Logical. Whether to remove the `csv.gz` file(s) after
#'   conversion to parquet. Defaults to TRUE.
#'
#' @returns `NULL` invisibly. Called for side effect of downloading data.
#'
#' @noRd
#' @examples
#' \dontrun{
#'   renmods_update_("this_yr")
#' }

renmods_update_ <- function(dataset, cleanup = TRUE) {
  cli_par()
  cli_h2("Updating '{dataset}' data from EnMoDS")

  download_csv(dataset)
  convert_parquet(dataset)

  # Record metadata
  cache_meta(datasets = dataset, update = TRUE)

  # Finally remove the csv.gz files
  if (cleanup) {
    s <- file.remove(cache_path(dataset))
    if (s) {
      cli_alert_success("csv.gz file successfull removed")
    } else {
      cli_alert_warning("Could not remove csv.gz file")
    }
  }
}

download_csv <- function(dataset, internal = FALSE) {
  path <- cache_path(dataset)
  url <- getOption("renmods.urls")[[dataset]]

  cli_alert_info("Downloading csv.gz from EnMoDS")
  cli_alert_success("Saving to cache: {path}")

  # Remove file from metadata - In case download aborted, metadata is correct
  if (!internal) {
    cache_meta(datasets = dataset, reset = TRUE)
  }

  httr2::request(url) |>
    httr2::req_progress() |>
    httr2::req_perform(path = path)

  cli_alert_success("Successfully downloaded")
}

convert_parquet <- function(dataset) {
  path_csv <- cache_path(dataset, "csv.gz")
  path_parquet <- cache_path(dataset, "parquet")
  path_parquet_temp <- cache_path(dataset, "parquet.tmp")

  cli_alert_info("Converting to Parquet: {path_parquet}")
  cli_alert_success("Saving to cache: {path_parquet}")

  con <- db_connect()
  var_cols <- c("Result_Value", db_time_cols(con, path_csv))
  var_cols <- paste0("'", var_cols, "': 'VARCHAR'", collapse = ",")

  # - Read csv
  # - Keep Result_Value and Time columns as VARCHAR for now
  #     - https://duckdb.org/docs/2.0/data/csv/auto_detection#type-detection
  #     - convert Result_Value when connecting
  #     - get dates and timezones before formatting date/time cols
  # fmt:skip
  sql_csv <- paste0(
    "read_csv(['", paste0(path_csv, collapse = "', '"), "'], ",
    "types = {", var_cols, "},",
    "compression = 'gzip')"
  )

  sql <- con |>
    duckdb::tbl_function(sql_csv) |>
    db_add_date(date_col = "ren_date") |>
    # Set sort to improve read times later
    dplyr::arrange(.data$Location_ID, .data$ren_date) |>
    dbplyr::sql_render() # Convert to sql string to use in parquet

  # Apply the formatting steps and convert to parquet
  # fmt: skip
  DBI::dbExecute(
    con,    
    paste0("COPY (", sql, ") TO '", path_parquet_temp, "' ",
           "(FORMAT parquet, COMPRESSION zstd)")
  )
  DBI::dbDisconnect(con)

  file.rename(path_parquet_temp, path_parquet)

  cli_alert_success("Successfully converted to Parquet")
}
