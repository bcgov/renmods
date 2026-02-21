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

check_type <- function(type) {
  t <- renmods()$types
  if (!all(type %in% t)) {
    rlang::abort(
      paste0(
        "Type must be one of '",
        paste0(t, collapse = "', '"),
        "'"
      ),
      call = NULL
    )
  }
}

check_cache <- function(type, force) {
  path <- cache_path(type)
  update <- FALSE

  if (!file.exists(path)) {
    update <- TRUE
  } else if (force) {
    update <- TRUE
    cli_alert_info("Forcing update of cached data")
  } else if (check_time_to_update(type)) {
    update <- TRUE
  }

  update
}

check_time_to_update <- function(type) {
  d <- cache_meta(type = type)$last_downloaded
  if (is.na(d)) {
    update <- TRUE
  } else {
    diff <- difftime(Sys.time(), d, units = "weeks")
    update <- diff > renmods()$update[type]
  }
  if (update) {
    update <- ask(
      "Data '{type}' is older than {renmods()$update[type]} weeks. Update data?",
      "Updating '{type}' data"
    )
  }
  update
}

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
          "Cannot work with ENMODS data without the `httpfs` extension",
          call = NULL
        )
      }
    } else {
      e
    }
  })
}
