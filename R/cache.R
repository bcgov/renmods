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
    create <- ask(
      "Cache directory does not exist. Create {path}?",
      "Creating cache directory {path}"
    )
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

cache_meta <- function(type = NULL, update = NULL) {
  path <- file.path(cache_dir(), "metadata.csv")

  if (file.exists(path)) {
    meta <- read.csv(path)
  } else {
    meta <- data.frame(
      type = renmods()$types,
      last_downloaded = NA_character,
      date_range = NA_character_,
      renmods_version = NA_character_
    )
  }
  if (!is.null(update)) {
    dates <- update |>
      cache_path() |>
      extract_date_range() |>
      dt_to_char()

    meta <- dplyr::rows_upsert(
      meta,
      data.frame(
        type = update,
        last_downloaded = as.character(round(Sys.time())),
        date_range = dates,
        renmods_version = as.character(packageVersion("renmods"))
      ),
      by = "type"
    )
  }
  write.csv(meta, path, row.names = FALSE)

  if (!is.null(type)) {
    meta <- dplyr::filter(meta, .data$type == .env$type)
  }
  invisible(meta)
}

cache_status <- function() {
  # TODO: Return list of files, dates, and sizes
}

cache_exists <- function() {
  # TODO: Need this?
}

cache_date <- function() {}
