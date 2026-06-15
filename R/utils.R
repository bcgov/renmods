#' Extract date range from gzip file metadata
#'
#' Reads the gzip file header to extract the original filename, then parses
#' the date range from the filename (expected format: YYYYMMDD).
#'
#' @param path Character. Path(s) to gzip file(s).
#'
#' @returns Character. Date range in format "YYYY-MM-DD to YYYY-MM-DD" or
#'   character vector if multiple paths provided.
#'
#' @references
#' - https://www.rfc-editor.org/rfc/rfc1952.html#page-5
#' - https://en.wikipedia.org/wiki/Gzip#File_structure
#' @export
#' @examplesIf interactive()
#' extract_date_range(cache_path("this_yr"))
#' extract_date_range(cache_path("yr_2_5"))
#' extract_date_range(cache_path("yr_5_10"))
#' extract_date_range(cache_path("historic"))
#'
#' extract_date_range(cache_path(c("this_yr", "historic")))

extract_date_range <- function(path) {
  # If multiple paths, recurse
  if (length(path) > 1) {
    dts <- purrr::map_chr(path, extract_date_range)
    return(dts)
  }

  con <- file(path, "rb")
  on.exit(close(con))

  # Read the first 200 bytes of raw data from the file to grab metadata
  # https://en.wikipedia.org/wiki/Gzip#File_structure
  meta <- readBin(path, what = "raw", n = 200)
  pos_flag <- 4 # Flags
  pos_xlen <- 11 # XLEN
  skip <- 0

  # Check flag that sets FNAME (whether we have an original file name)
  # First grab the 4 byte which contains the flags
  flag <- meta[pos_flag]

  # The third bit (FNAME position) in flags is represented as 0x08 (2^3)
  # Now assess if 0x08 (the FNAME position) is set in any flag byte
  # This is a 'mask'
  named <- bitwAnd(as.integer(flag), 0x08) == 8
  if (!named) {
    return(NA_character_)
  }

  # Skip ahead to XLEN
  readBin(con, "raw", n = 6)

  # Also check if the FEXTRA flag is set (because we need to skip extra if so)
  extra <- bitwAnd(as.integer(flag), 0x04) == 4
  # TODO: TEST THIS. No file had it so couldn't test
  if (extra) {
    skip <- as.integer(meta[c(pos_xlen, pos_xlen + 1)])
  }

  pos_name <- pos_xlen + skip

  # Finally, read the filename (Null-terminated so we read until we hit NULL/0)
  # Read null-terminated filename
  name <- meta[pos_name:length(meta)]
  name <- name[seq_len(which(name == 0x00)[1])]
  name <- rawToChar(name)

  # Extract date range from name
  date_range <- stringr::str_extract_all(name, "\\d{8}", simplify = TRUE) |>
    strptime("%Y%m%d", tz = "UTC") |>
    as.Date() |>
    dt_to_char()

  date_range
}

#' Convert date vector to character range
#'
#' Converts a two-element date vector into a single character string
#' formatted as "YYYY-MM-DD to YYYY-MM-DD".
#'
#' @param dates Date vector of length 2.
#'
#' @returns Character. Date range as single string.
#'
#' @noRd
#' @examples
#' dt_to_char(as.Date(c("2024-01-01", "2024-12-31")))

dt_to_char <- function(dates) {
  paste0(dates, collapse = " to ")
}

#' Convert character range to date vector
#'
#' Parses a character string formatted as "YYYY-MM-DD to YYYY-MM-DD" into
#' a two-element date vector. If only one date is provided, assumes start
#' date of 1900-01-01.
#'
#' @param dates Character. Date range as single string.
#'
#' @returns Date vector of length 2.
#'
#' @noRd
#' @examples
#' char_to_dt("2024-01-01 to 2024-12-31")
#' char_to_dt("2024-12-31")

char_to_dt <- function(dates) {
  dt <- stringr::str_split_1(dates, " to ")
  if (length(dt) == 1) {
    dt <- c("1900-01-01", dt)
  }
  as.Date(dt)
}

#' Determine which data types cover a date range
#'
#' Queries cache metadata to find which data types (this_yr, yr_2_5, yr_5_10,
#' historic) contain data overlapping with the requested date range.
#'
#' @param dates Date or character vector of length 2. Start and end dates.
#'
#' @returns Character vector. Data types that overlap with the date range.
#'
#' @noRd
#' @examples
#' which_data_types(c("2026-01-01", "2026-01-15"))  # this_yr
#' which_data_types(c("2024-12-10", "2024-12-15"))  # yr_2_5
#' which_data_types(c("2021-12-10", "2021-12-15"))  # yr_5_10
#' which_data_types(c("2010-01-01", "2010-01-15"))  # historic
#'
#' # Multiple ranges
#' which_data_types(c("2024-12-10", "2025-01-15"))  # this_yr, yr_2_5

which_data_types <- function(dates) {
  meta <- cache_meta() |>
    dplyr::mutate(
      in_range = purrr::map_lgl(.data$date_range, \(dt) {
        dates_data <- char_to_dt(dt)
        !(dates_data[2] < dates[1] | dates_data[1] > dates[2])
      })
    )
  if (!any(meta$in_range)) {
    cli_abort(
      "No data types cover this range of data ({dates}). See `cache_status()`. Do you need to update your data? See `renmods_update(\"this_yr\")`",
      call = NULL
    )
  }
  meta |>
    dplyr::filter(.data$in_range) |>
    dplyr::pull(.data$type)
}

#' Prompt user for confirmation in interactive mode
#'
#' Displays a warning message and prompts for yes/no confirmation in
#' interactive sessions. In non-interactive mode, automatically proceeds
#' with action and displays info message.
#'
#' @param msg Character. Question/Query to display (used as prompt).
#' @param no_ask Character. Message to display in non-interactive mode.
#' @param call Environment. Calling environment for message interpolation.
#'   Allows use of `{variable}` in cli messages where the variable comes from
#'   the calling environment.
#'
#' @returns Logical. `TRUE` if user confirmed or non-interactive, `FALSE` if
#'   user declined.
#'
#' @noRd
#' @examples
#' ask("Continue?", "Continuing automatically")

ask <- function(msg, no_ask = NULL, call = rlang::caller_env()) {
  if (rlang::is_interactive()) {
    cli_alert_warning(msg, .envir = call)
    go <- utils::askYesNo(msg = "", default = TRUE)
    go <- isTRUE(go)
  } else {
    go <- TRUE
    cli_alert_info(no_ask, .envir = call)
  }
  go
}

#' Reads/Creates metadata table
#'
#' @returns Tibble of metadata
#'
#' @noRd
#' @examples
#' read_meta()

read_meta <- function() {
  path <- file.path(cache_dir(), "metadata.csv")

  if (file.exists(path)) {
    # Check if any files are missing and reset if so.
    meta <- utils::read.csv(path) |>
      lapply(as.character) |>
      dplyr::as_tibble()

    if (!all(is.na(meta$path))) {
      p <- meta$path
      p[is.na(p)] <- ""
      meta[!file.exists(p), ] <- meta_blank()[!file.exists(p), ]
      utils::write.csv(meta, path, row.names = FALSE) # Update any missing files
    }
  } else {
    meta <- meta_blank()
  }
  meta
}

#' Write metadata to file
#'
#' @param meta Data frame to write
#'
#' @returns `NULL` invisibly. Called for side effect of saving data.
#'
#' @noRd
write_meta <- function(meta) {
  path <- file.path(cache_dir(), "metadata.csv")
  utils::write.csv(meta, path, row.names = FALSE)
}

#' Create empty meta data table
#'
#' Used to create initial table or to reset specific data types as they start
#' updating (this way if the update isn't complete, data is listed as missing).
#'
#' @param types Data types to include
#'
#' @returns Tibble of blank metadata
#'
#' @noRd
#' @examples
#' meta_blank()
#' meta_blank("this_yr")

meta_blank <- function(types = renmods()$types) {
  dplyr::tibble(
    type = types,
    last_downloaded = NA_character_,
    date_range = NA_character_,
    renmods_version = NA_character_,
    path = NA_character_
  )
}
