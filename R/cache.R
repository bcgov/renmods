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

cache_dir <- function() {
  path <- getOption(
    "renmods.cache_dir",
    default = rappdirs::user_data_dir("renmods")
  ) |>
    normalizePath(mustWork = FALSE)

  if (!dir.exists(path)) {
    if (interactive()) {
      cli_alert_warning("Cache directory does not exist.")
      cli_ul("Create {path}?")
      go <- utils::askYesNo(msg = "", default = TRUE)
      if (isTRUE(go)) create <- TRUE else create <- FALSE
    } else {
      create <- TRUE
    }
    if (create) {
      created <- dir.create(path)
      if (created) cli_alert_success("Successfully created cache directory")
    } else {
      cli_abort("Cannot continue without a cache dir", call = NULL)
    }
  }

  path
}

cache_path <- function(type) {
  check_type(type)
  path <- file.path(cache_dir(), paste0(type, ".csv.gz"))
  path
}

cache_status <- function() {
  # TODO: Return list of files, dates, and sizes
}

cache_exists <- function() {
  # TODO: Need this?
}

cache_date <- function() {}
