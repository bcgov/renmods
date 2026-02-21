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

#' Title
#'
#' @param date_range
#' @param type
#'
#' @returns
#'
#' @export
#' @examples
#' db <- renmods_connect(c("2025-01-01", "2025-02-01"))
#' db <- renmods_connect()

renmods_connect <- function(date_range = NULL, types = "all") {
  if (!is.null(date_range)) {
    date_range <- as.Date(date_range)
    types <- which_data_types(date_range)
  } else {
    types <- renmods()$types
  }

  cli_alert_info("Reading data {types}")

  path <- cache_path(types)

  # https://duckdb.org/docs/stable/data/multiple_files/overview#csv
  sql <- paste0(
    "read_csv(['",
    paste0(path, collapse = "', '"),
    "'], compression = 'gzip', union_by_name = true, filename = true)"
  )

  tbl <- db_connect() |>
    duckdb::tbl_function(sql) |>
    dplyr::filter(
      # !! required because otherwise indexing [1] creates problems with the SQL commands
      # !! means evaluate right away and pass the output on
      .data$Observed_Date_Time >= !!date_range[1],
      .data$Observed_Date_Time <= !!date_range[2]
    )
}

db_connect <- function() {
  con <- DBI::dbConnect(
    duckdb::duckdb(),
    config = list(
      autoinstall_known_extensions = TRUE,
      autoload_known_extensions = TRUE
    )
  )
  check_db_httpsfs(con)
  con
}
