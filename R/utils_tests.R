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
#

# Make a temp dir and set options(renmods.cache_dir = tmp), returning the old options.
# Copy the mini data files from system.file("extdata", ..., package = "renmods") into it.
# Write metadata.csv with a current last_downloaded, the package version, and the date ranges, so check_cache() treats everything as fresh and never tries to download.

use_example_cache <- function() {
  # Create an example cache
  temp_cache <- file.path(tempdir(), "renmods_cache")
  dir.create(temp_cache, showWarnings = FALSE)

  file.copy(
    list.files(
      system.file("extdata", "example_cache", package = "renmods"),
      full.names = TRUE
    ),
    temp_cache,
    overwrite = TRUE
  )

  # Set options so we have correct path location in metadata
  opts <- options(renmods.cache_dir = temp_cache)

  # Refresh metadata so check_cache() sees the data as current
  # DO NOT set the renmods package version, if out of date, it should error so
  # we recreate the example cache data.
  meta <- utils::read.csv(cache_path("metadata")) |>
    dplyr::mutate(
      path = cache_path(.data$dataset, "parquet"),
      last_downloaded = as.character(round(Sys.time()))
    )
  write_meta(meta)

  if (!check_version("this_yr")) {
    cli_abort("Update the example cache data!", call = NULL)
  }

  invisible(opts)
}

#' Create example data parquet files
#'
#' @param dataset Character. "this_yr", "yr_2_5", "yr_5_10", or "historic"
#' @param n Numeric. Samples per location
#' @param n_max Numeric. Maximum number of samples total. Example data is
#' truncated to this.
#'
#' @returns Writes an example parquet data set to the inst/extdata/example_cache
#' folder.
#'
#' @noRd
example_data <- function(
  dataset,
  dir = "inst/extdata/example_cache",
  n = 50,
  n_max = 200
) {
  # Only keep some columns
  keep <- c(
    "Location_ID",
    "Location_Name",
    "Observed_Property_ID",
    "Observed_Property_Name",
    "Observed_Property_Result_Type",
    "Observed_Date_Time",
    "Analysis_Method_ID",
    "Result_Value",
    "Result_Unit",
    "Result_Status",
    "Result_Grade",
    "ren_date"
  )

  df <- renmods_connect(
    datasets = dataset,
    result_type = "all",
    convert_times = FALSE
  ) |>
    suppressWarnings() |>
    dplyr::collect() |>
    dplyr::slice_sample(
      n = n,
      by = c("Location_ID", "Observed_Property_Result_Type")
    ) |>
    dplyr::arrange(.data$Location_ID, .data$Observed_Date_Time) |>
    dplyr::slice(seq_len(.env$n_max)) |>
    dplyr::select(dplyr::all_of(keep)) |>
    dplyr::mutate(
      Location_Name = paste0(
        "Example Location no.",
        as.numeric(factor(.data$Location_ID))
      ),
      Location_ID = paste0("Location", as.numeric(factor(.data$Location_ID)))
    )

  # Write with the same column types and sort order as the real cache
  con <- db_connect()
  duckdb::duckdb_register(con, "example", df)
  DBI::dbExecute(
    con,
    paste0(
      "COPY (SELECT * FROM example ORDER BY Location_ID, ren_date) ",
      "TO '",
      file.path(dir, paste0(dataset, ".parquet")),
      "' ",
      "(FORMAT parquet, COMPRESSION zstd)"
    )
  )
  duckdb::duckdb_unregister(con, "example")
}

#' Create example cache
#'
#' Used by data-raw/test_data.R to create example cache parquet files and
#' metadata.csv.
#'
#' @param datasets Example datasets to create
#' @param dir Location of the example cache
#' @param n Number of samples per location id to include
#' @param n_max Total number of samples to include
#'
#' @returns Creates/overwrites the example cache
#'
#' @noRd

create_example_cache <- function(
  datasets = renmods()$datasets,
  dir = "inst/extdata/example_cache",
  n = 50,
  n_max = 200
) {
  # Start from scratch
  if (dir.exists(dir)) {
    unlink(dir, recursive = TRUE)
  }
  dir.create(dir)

  set.seed(111)

  # Create the example parquet files
  purrr::walk(datasets, \(d) example_data(dataset = d, n = n, n_max = n_max))

  # Create the example metadata files
  file.copy(cache_path("metadata"), dir)
}

create_example_download_file <- function(
  dataset = "this_yr",
  date_example = "20250101_to_20261107.csv",
  where = testthat::test_path("fixtures")
) {
  download_csv(dataset, internal = TRUE)

  test_data_path <- file.path(where, date_example)
  lines <- readLines(gzfile(cache_path(dataset)), n = 5)
  writeLines(lines, test_data_path)
  system2(
    "gzip",
    c("-c", test_data_path),
    stdout = file.path(where, paste0(dataset, ".csv.gz"))
  )

  # Clean up
  unlink(test_data_path) # Remove uncompressed csv
  unlink(cache_path(dataset)) # Remove original download file
}
