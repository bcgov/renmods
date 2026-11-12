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

#' Get or create cache directory
#'
#' Returns the path to the renmods cache directory. By default, creates the
#' directory if it doesn't exist (with user confirmation in interactive mode).
#' The cache location can be customized via the `renmods.cache_dir` option.
#'
#' @param check_only Logical. If `TRUE`, only checks if cache directory exists
#'   without creating it or prompting user.
#'
#' @returns Character. Path to cache directory (when `check_only = FALSE`) or
#'   logical indicating if cache exists (when `check_only = TRUE`).
#'
#' @export
#' @examples
#' cache_dir(check_only = TRUE)
#' \dontrun{
#' cache_dir()
#' }
cache_dir <- function(check_only = FALSE) {
  path <- getOption(
    "renmods.cache_dir",
    default = tools::R_user_dir("renmods", which = "data")
  ) |>
    normalizePath(mustWork = FALSE)

  if (check_only) {
    return(dir.exists(path))
  }

  if (!dir.exists(path)) {
    create <- ask(
      "Cache directory does not exist. Create {path}?",
      "Creating cache directory {path}"
    )
    if (create) {
      created <- dir.create(path, recursive = TRUE)
      if (created) cli_alert_success("Successfully created cache directory")
    } else {
      cli_abort("Cannot continue without a cache dir", call = NULL)
    }
  }

  path
}

#' Get cache file paths for data types
#'
#' Returns the full file paths for where EnMoDS data files would be cached. Note
#' they do not have to exist.
#'
#' @param types Character. Data types to get paths for.
#'
#' @returns Character vector. Full file paths to cached data files.
#'
#' @noRd
#' @examples
#' cache_path("this_yr")
#' cache_path(c("this_yr", "yr_2_5"))
#' cache_path("this_yr", ext = "parquet")
#' cache_path(c("this_yr", "yr_2_5"), ext = "parquet")

cache_path <- function(types, ext = "csv.gz") {
  if (length(types) == 1 && types == "metadata") {
    return(file.path(cache_dir(), "metadata.csv"))
  }

  types <- check_types(types)
  path <- file.path(cache_dir(), paste0(types, ".", ext))
  path
}

#' Fetch or update cache metadata
#'
#' This is an internal function to prevent users from accidentally updating
#' the last download dates for the cache. Users should use `cache_status()`
#' instead.
#'
#' @param types Character. Types of EnMoDS data to check.
#' @param update Logical. Whether or not to update the metadata (assumes data
#'   has just been downloaded).
#' @param reset Logical. Whether to reset the metadata for a data type to blank.
#'   Useful for just before when downloading, to ensure if the download is
#'   cancelled, that the metadata correctly records the data status as missing.
#'
#' @returns Data frame with cache metadata (type, last_downloaded, date_range,
#'   renmods_version, path).
#'
#' @noRd
#' @examples
#' cache_meta()

cache_meta <- function(types = renmods()$types, update = FALSE, reset = FALSE) {
  meta <- read_meta()

  if (!update && !reset) {
    if (!is.null(types)) {
      meta <- dplyr::filter(meta, .data$type %in% .env$types)
    }
    return(meta)
  }

  if (update) {
    # Which files do we have (this will be run before csv.gz files are removed)
    f_csv <- cache_path(types)
    f_csv <- f_csv[file.exists(f_csv)]

    f_parquet <- cache_path(types, "parquet")
    f_parquet <- f_parquet[file.exists(f_parquet)]

    dates <- extract_date_range(f_csv)

    meta <- dplyr::rows_upsert(
      meta,
      dplyr::tibble(
        type = types,
        last_downloaded = as.character(round(Sys.time())),
        date_range = dates,
        renmods_version = as.character(utils::packageVersion("renmods")),
        path = f_parquet
      ),
      by = "type"
    )

    cli_alert_success("Cache metadata updated")
  } else if (reset) {
    meta <- dplyr::rows_upsert(meta, meta_blank(types), by = "type")
  }

  write_meta(meta)
}


#' View cache status
#'
#' Returns information about cached EnMoDS data including when each data type
#' was last downloaded, the date range it covers, and the file path.
#'
#' @returns Data frame with columns:
#' - `type`: Data type (this_yr, yr_2_5, yr_5_10, historic)
#' - `last_downloaded`: Date/time of last download
#' - `date_range`: Date range covered by the data
#' - `renmods_version`: Package version used to download data
#' - `path`: File path to cached data
#'
#' @export
#' @examples
#' # View status of all cached data
#' cache_status()
#'
#' # After download
#' \dontshow{op <- renmods:::example_cache()}
#' cache_status()
#' \dontshow{options(op)}

cache_status <- function() {
  if (cache_dir(check_only = TRUE)) {
    cache_meta()
  } else {
    cli_inform("No cache")
  }
}

#' Remove cached data
#'
#' Deletes cached EnMoDS parquet data files. Use with caution as this will
#' require re-downloading data. In interactive mode, prompts for confirmation
#' before deletion.
#'
#' @param types Character. Which data types to remove. Either "all" (default)
#'   to remove all cached data and the cache directory, or one or more of
#'   "this_yr", "yr_2_5", "yr_5_10", "historic".
#'
#' @returns `TRUE` invisibly.
#'
#' @export
#' @examples
#' \dontrun{
#' # Remove all cached data
#' cache_remove()
#'
#' # Remove specific data types
#' cache_remove(types = c("this_yr", "yr_2_5"))
#'
#' # Remove just historic data
#' cache_remove(types = "historic")
#' }
cache_remove <- function(types = "all") {
  if (!cache_dir(check_only = TRUE)) {
    cli_inform("No cache to remove")
    return(invisible(TRUE))
  }

  if (length(types) == 1 && types == "all") {
    full <- TRUE
    f <- c(
      cache_dir(),
      list.files(
        cache_dir(),
        full.names = TRUE,
        recursive = TRUE,
        include.dirs = TRUE
      )
    )
  } else {
    full <- FALSE
    types <- check_types(types)
    f <- cache_path(types)
  }

  cli_alert_info("Cache to be removed:")
  cli_ul(f)

  remove <- ask(
    "Are you sure you would like to completely these files/folders?",
    "Removing the cache"
  )
  if (remove) {
    unlink(f, recursive = TRUE)
  }
  if (!full) {
    cache_meta()
  } # Ping to update removed file status

  invisible(TRUE)
}
