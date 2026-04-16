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

#' Validate and normalize data type arguments
#'
#' Checks that data types are valid and expands "all" to a vector of all data
#' types.
#'
#' @param types Character. Data types to validate.
#'
#' @returns Character vector. Validated data types.
#'
#' @noRd
#' @examples
#' check_types("this_yr")
#' check_types("all")
#' check_types(c("this_yr", "yr_2_5"))

check_types <- function(types) {
  t <- renmods()$types

  if (length(types) == 1 && types == "all") {
    return(t)
  }

  if (!all(types %in% t)) {
    rlang::abort(
      paste0(
        "Type must be one of '",
        paste0(t, collapse = "', '"),
        "'"
      ),
      call = NULL
    )
  }
  types
}

#' Check date are in correct format
#'
#' Check and if valid, convert dates/text to date format.
#'
#' @param dates Vector to test for coercion to dates.
#' @param range Logical. Whether to test if `dates` includes a date range.
#'
#' @returns `dates` as R Date format
#'
#' @noRd
#' @examples
#' check_dates(Sys.Date())
#' check_dates("2024-02-29")
#' # check_dates("2025-13-01") # Error
check_dates <- function(dates, range = FALSE) {
  tryCatch(as.Date(dates), error = \(e) {
    cli_abort(
      "Dates must be valid dates in the format of YYYY-MM-DD",
      call = NULL
    )
  })

  if (range) {
    if (length(dates) != 2) {
      cli_abort(
        "{.var dates} must have two values, a start date and an end date"
      )
    }
    dates <- sort(dates)
  }

  # To avoid weird problems with as.Date on POSIXct in R base, truncate first.
  # (could also use lubridate::as_date() to avoid this issue)

  dates <- stringr::str_extract(dates, "^\\d{4}-\\d{2}-\\d{2}") |>
    as.Date()

  dates
}

#' Check if cache needs updating
#'
#' Determines whether cached data needs to be updated based on existence,
#' age, and force parameter.
#'
#' @param type Character. Single data type to check.
#' @param force Logical. If `TRUE`, forces update regardless of cache status.
#'
#' @returns Logical. `TRUE` if data should be updated, `FALSE` otherwise.
#'
#' @noRd
#' @examples
#' check_cache("this_yr")
#' check_cache("this_yr", force = TRUE)

check_cache <- function(type, force = FALSE) {
  update <- FALSE

  path <- cache_path(type)
  if (!file.exists(path)) {
    update <- TRUE
  } else if (force) {
    update <- TRUE
    cli_alert_info("Forcing update of cached data")
  } else if (!check_version(type)) {
    cli_alert_info(
      "Cached data is from an older version of the package and should be updated"
    )
    update <- TRUE
  } else {
    update <- check_time_to_update(type)
  }

  update
}

#' Check if cache needs updating
#'
#' Internal function to determine if cached needs updating.
#'
#' @param type Character. Data type to check.
#'
#' @returns Logical. `TRUE` if data needs updating, `FALSE` otherwise.
#'
#' @noRd
#' @examples
#' check_time_to_update("this_yr")
check_time_to_update <- function(type) {
  d <- cache_meta(types = type)$last_downloaded

  if (is.na(d)) {
    # Always update if no data
    return(TRUE)
  }

  w <- renmods()$update[type]
  diff <- difftime(Sys.time(), d, units = "weeks")
  update <- diff > renmods()$update[type]

  if (update) {
    update <- ask(
      "Data '{type}' is older than {w} weeks. Update data?",
      "Updating '{type}' data"
    )
  } else {
    cli_alert_success("{type}: Last downloaded {d} (within {w} week(s))")
  }
  update
}

#' Check and install DuckDB httpfs extension
#'
#' Verifies that the httpfs extension is available in DuckDB and prompts
#' to install it if missing. This extension is required to read CSV files.
#'
#' @param con DuckDB connection object.
#'
#' @returns DuckDB connection object (invisibly).
#'
#' @noRd
#' @examples
#' con <- DBI::dbConnect(duckdb::duckdb())
#' check_db_httpsfs(con)

check_db_httpsfs <- function(con) {
  con <- tryCatch(DBI::dbExecute(con, "LOAD httpfs"), error = \(e) {
    if (stringr::str_detect(e$message, "INSTALL httpfs")) {
      install <- ask(
        "'httpfs', a DuckDB extension required to read ENMODS data, is not is not available, install?",
        "Installing DuckDB extension 'httpfs'"
      )
      if (install) {
        DBI::dbExecute(con, "INSTALL httpfs")
        return(con)
      } else {
        cli_abort(
          "Cannot work with ENMODS data without the 'httpfs' extension",
          call = NULL
        )
      }
    } else {
      e
    }
  })
}

#' Check and install DuckDB icu extension
#'
#' Verifies that the icu extension is available in DuckDB and prompts
#' to install it if missing. This extension is required to handle timezones in
#' date/times.
#'
#' @param con DuckDB connection object.
#'
#' @returns DuckDB connection object (invisibly).
#'
#' @noRd
#' @examples
#' con <- DBI::dbConnect(duckdb::duckdb())
#' check_db_icu(con)

check_db_icu <- function(con) {
  con <- tryCatch(DBI::dbExecute(con, "LOAD icu"), error = \(e) {
    if (stringr::str_detect(e$message, "INSTALL icu")) {
      install <- ask(
        "'icu', a DuckDB extension required to handle date/times in ENMODS data, is not is not available, install?",
        "Installing DuckDB extension 'icu'"
      )
      if (install) {
        DBI::dbExecute(con, "INSTALL icu")
        return(con)
      } else {
        cli_abort(
          "Cannot work with ENMODS data without the 'icu' extension",
          call = NULL
        )
      }
    } else {
      e
    }
  })
}

#' Check data version against package version
#'
#' @param type Character. Single data type to check.
#'
#' @returns TRUE if matches, FALSE if data older than package
#'
#' @noRd
#' @examples
#' check_version("this_yr")

check_version <- function(type) {
  v <- cache_meta(types = type)$renmods_version
  v >= packageVersion("renmods")
}
