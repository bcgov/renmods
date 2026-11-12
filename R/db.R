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

#' Connect to EnMoDS data via DuckDB
#'
#' Creates a DuckDB connection to cached EnMoDS Parquet data. The database table can be
#' filtered using dplyr before collecting into a data frame with `collect()`.
#' Using `dates` (date range) or `datasets` prefilters the data to a
#' specific date range or specific data file. But if both are supplied, `dates`
#' takes precedence. Only the data files required will be connected to and the
#' fewer data sources connected to and the smaller the dataset, the quicker the
#' `collect()` function will run.
#'
#' Note that EnMoDS stores date/times as character/text fields with the timezone
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
#' @param datasets Character. Datasets to connect to. One or more of
#'   "this_yr", "yr_2_5", "yr_5_10", "historic", or "all" (default "all").
#'   Ignored if `dates` is specified.
#' @param convert_times Logical. Whether or not to convert character date/times
#'   to date/time format in R. Defaults to `TRUE`. If `FALSE` remain as
#'   character.
#' @param tz_disp Character. Timezone in which to display the data. Default is
#'   America/Vancouver (i.e. UTC-7).
#' @param types Character. Deprecated, use `datasets` instead.
#'
#' @returns A `tbl_duckdb_connection` object - a lazy DuckDB table. Use dplyr
#'   functions to filter/select, then `collect()` to load into R memory.
#'
#' @export
#' @examples
#' \dontshow{op <- renmods:::use_example_cache()}
#'
#'
#' # All data
#' db <- renmods_connect()
#'
#' # Use dplyr to filter and manipulate the data
#' library(dplyr)
#'
#' # Filter and collect into a data frame
#' df <- renmods_connect() |>
#'   filter(Location_ID %in% c("E327371", "E300230")) |>
#'   collect()
#'
#' # Automatically connects only to datasets required for a specific date range
#' db <- renmods_connect(dates = c("2025-01-01", "2025-02-01"))
#' db <- renmods_connect(dates = c("1990-01-01", "1990-02-01"))
#'
#' # By default, only returns data where Observed_Property_Result_Type is NUMERIC
#' # But you can specify non-numeric data
#' db <- renmods_connect(result_type = "non-numeric")
#' select(db, "Observed_Property_ID", "Result_Value")
#'
#' # Or even *all* data
#' # Note: This will result in a mix of numeric and non-numeric and
#' #  Result_Value will be "character"
#' db <- renmods_connect(result_type = "all")
#' select(db, "Observed_Property_ID", "Result_Value")
#'
#' # Explore the data and column names
#' colnames(db)
#' glimpse(db)
#'
#' # Filter and collect specific data
#' df <- renmods_connect() |>
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
#'
#' \dontshow{options(op)}

renmods_connect <- function(
  dates = NULL,
  datasets = "all",
  result_type = "numeric",
  convert_times = TRUE,
  tz_disp = "Etc/GMT+7",
  types = NULL
) {
  if (!missing(types)) {
    cli_alert("{.arg types} has been deprecated, use {.arg datasets} instead")
    datasets <- types
  }

  if (!is.null(dates)) {
    dates <- check_dates(dates, range = TRUE)
    datasets <- which_datasets(dates)
  } else if (!is.null(datasets)) {
    datasets <- check_datasets(datasets)
  } else {
    datasets <- renmods()$datasets
  }

  if (
    is.null(result_type) ||
      !is.character(result_type) ||
      length(result_type) > 1 ||
      !result_type %in% c("numeric", "non-numeric", "all")
  ) {
    cli_abort(
      "{.arg result_type} must be one of 'numeric', 'non-numeric', or 'all'",
      call = NULL
    )
  }

  # Check cache exists
  if (!cache_dir(check_only = TRUE)) {
    cli_abort(
      "No EnMoDS data has been downloaded. First try `renmods_update()`",
      call = NULL
    )
  }

  cli_alert_info(
    paste0(
      "Connecting to {.val {datasets}} data",
      if (!is.null(dates)) " for dates between {dates[1]} and {dates[2]}"
    )
  )

  # Check we have all data and that it's up-to-date
  purrr::walk(datasets, \(t) {
    u <- check_cache(t)
    if (u) renmods_update_(t)
  })

  path <- cache_path(datasets, "parquet")

  # https://duckdb.org/docs/stable/data/multiple_files/overview#csv
  sql <- paste0(
    "read_parquet(['",
    paste0(path, collapse = "', '"),
    "'], union_by_name = true, filename = true)"
  )

  tbl <- db_connect(tz_disp = tz_disp) |>
    duckdb::tbl_function(sql)

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

  # Filter & convert by result_type
  if (result_type == "numeric") {
    tbl <- tbl |>
      dplyr::filter(.data$Observed_Property_Result_Type == "NUMERIC") |>
      dplyr::mutate(Result_Value = as.numeric(.data$Result_Value))
  } else if (result_type == "non-numeric") {
    tbl <- dplyr::filter(tbl, .data$Observed_Property_Result_Type != "NUMERIC")
  } else if (result_type == "all") {
    cli_warn(
      "Using {.arg result_type = 'all'} means that 'Result_Values' may be a combination of numeric, categorical, and/or character values",
      call = NULL
    )
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

db_connect <- function(tz_disp = "Etc/GMT+7") {
  con <- DBI::dbConnect(
    duckdb::duckdb(),
    config = list(
      autoinstall_known_extensions = TRUE,
      autoload_known_extensions = TRUE
    )
  )
  check_db_httpsfs(con)
  check_db_icu(con)
  DBI::dbExecute(con, paste0("SET TimeZone = '", tz_disp, "'"))
  con
}

#' Disconnect from the database
#'
#' @param tbl DuckDB tbl created with [renmods_connect()]
#'
#' @returns `NULL` invisibly. Called for side effect of disconnecting database.
#'
#' @export
#' @examples
#' \dontshow{op <- renmods:::use_example_cache()}
#' db <- renmods_connect()
#' renmods_disconnect(db)
#' \dontshow{options(op)}

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
