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

#' Connect to ENMODS data via DuckDB
#'
#' Creates a DuckDB connection to cached ENMODS data. The database table can be
#' filtered using dplyr before collecting into a data frame with `collect()`.
#' Using `dates` (date range) or `types` (data types) prefilters the data to a
#' specific date range or specific data file. But if both are supplied, `dates`
#' takes precedence. Only the data files required will be connected to and the
#' fewer data sources connected to and the smaller the dataset, the quicker the
#' `collect()` function will run.
#'
#' Note that ENMODS stores date/times as character/text fields with the timezone
#' indicated by +/- offset (e.g., '-08:00'). However, in R all values in a
#' column must use the same timezone. Therefore times are converted to UTC-7:00
#' (called `Etc/GMT+7`, note that `+` is correct; see the [Wikipedia page on
#' timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)).
#' The original timezone from `Observed_Date_Time` is stored in a new field
#' `ren_tz` for reference. You can convert to any timezone using the
#' [lubridate::with_tz()] function.
#'
#' @param dates Character or Date vector of length 2. Start and end dates for
#'   filtering data ("YYYY-MM-DD"). Note that data is filtered by the
#'   `Observed_Date_Time` field.
#' @param types Character. Data types to connect to. One or more of
#'   "this_yr", "yr_2_5", "yr_5_10", "historic", or "all" (default "all").
#'   Ignored if `dates` is specified.
#' @param convert_times Logical. Whether or not to convert character date/times
#'   to date/time format in R. Defaults to `TRUE`. If `FALSE` remain as
#'   character.
#'
#' @returns A `tbl_duckdb_connection` object - a lazy DuckDB table. Use dplyr
#'   functions to filter/select, then `collect()` to load into R memory.
#'
#' @export
#' @examplesIf interactive()
#' # All data
#' db <- renmods_connect()
#'
#' # All current data
#' db <- renmods_connect(types = "this_yr")
#'
#' # Connect only to data types required for a specific date range
#' db <- renmods_connect(dates = c("2025-01-01", "2025-02-01"))
#' db <- renmods_connect(dates = c("1990-01-01", "1990-02-01"))
#'
#' # Use dplyr to manipulate the data
#' library(dplyr)
#'
#' # Explore the data and column names
#' colnames(db)
#' glimpse(db)
#'
#' # Filter and collect specific data
#' df <- db |>
#'   filter(Location_ID %in% c("E327371", "E300230")) |>
#'   select(
#'     "Location_ID", "Location_Name", "Observed_Date_Time",
#'     "Observed_Property_Name", "Result_Value", "Result_Unit",
#'     "Analysis_Method_ID"
#'   ) |>
#'   collect()
#'
#' # Remember to shut down the connection when you're done
#' renmods_disconnect(db)

renmods_connect <- function(dates = NULL, types = "all", convert_times = TRUE) {
  if (!is.null(dates)) {
    dates <- check_dates(dates, range = TRUE)
    types <- which_data_types(dates)
  } else if (!is.null(types)) {
    types <- check_types(types)
  } else {
    types <- renmods()$types
  }

  # Check cache exists
  if (!cache_dir(check_only = TRUE)) {
    cli_abort(
      "No ENMODS data has been downloaded. First try `renmods_update()`",
      call = NULL
    )
  }

  cli_alert_info(
    paste0(
      "Connecting to {.val {types}} data",
      if (!is.null(dates)) " for dates between {dates[1]} and {dates[2]}"
    )
  )

  # Check we have all data and that it's up-to-date
  purrr::walk(types, \(t) {
    u <- check_cache(t)
    if (u) renmods_update_(t)
  })

  path <- cache_path(types)

  # https://duckdb.org/docs/stable/data/multiple_files/overview#csv
  sql <- paste0(
    "read_csv(['",
    paste0(path, collapse = "', '"),
    "'], compression = 'gzip', union_by_name = true, filename = true)"
  )

  tbl <- db_connect() |>
    duckdb::tbl_function(sql) |>
    db_add_date(date_col = "ren_date")

  if (!is.null(dates)) {
    tbl <- tbl |>
      dplyr::filter(
        # !! to unquote and eval right away
        .data$ren_date >= !!dates[1],
        .data$ren_date <= !!dates[2]
      )
  }

  # Fix all date/times
  if (convert_times) {
    tbl <- db_fmt_times(tbl)
  }

  tbl
}

#' Create general DuckDB connection with proper configuration
#'
#' Establishes a general DuckDB connection with autoinstall and autoload of
#' extensions enabled, and checks for httpfs and icu extension availability.
#'
#' The data base connection converts all date/times to UTC-7:00 (called `Etc/GMT+7`
#' see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List).
#'
#' Note that it is not currently connected to any files.
#'
#' @returns DuckDB connection object.
#'
#' @noRd
#' @examples
#' con <- db_connect()

db_connect <- function() {
  con <- DBI::dbConnect(
    duckdb::duckdb(),
    config = list(
      autoinstall_known_extensions = TRUE,
      autoload_known_extensions = TRUE
    ),
    timezone_out = "Etc/GMT+7", # Otherwise defaults to UTC
    tz_out_convert = "with" # Convert timezones, do not force
  )
  check_db_httpsfs(con)
  check_db_icu(con)
  con
}

#' Disconnect from the database
#'
#' @param tbl DuckDB tbl created with [renmods_connect()]
#'
#' @returns `NULL` invisibly. Called for side effect of disconnecting database.
#'
#' @export
#' @examplesIf interactive()
#' db <- renmods_connect()
#' renmods_disconnect(db)

renmods_disconnect <- function(tbl) {
  if (!inherits(tbl, "tbl_duckdb_connection")) {
    cli_abort(
      "{.arg tbl} must be a `tbl_duckdb_connection` object from 
      {.fn renmods_connect}",
      call = NULL
    )
  }

  con <- dbplyr::remote_con(tbl)
  DBI::dbDisconnect(con, shutdown = TRUE)
  invisible()
}
