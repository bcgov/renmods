#' Create new field with local date
#'
#' Converts a time/date column to just local date (i.e. truncates the time
#' and converts to date).
#'
#' @param tbl DuckDB tbl created with [renmods_connect()]
#' @param time_col Character. Field/Column name for date/time column from which
#' to extract a date.
#' @param date_col Character. Name of the new field/column to create.
#'
#' @returns A `tbl_duckdb_connection` object - a lazy DuckDB table. With the
#' additional field.
#'
#' @export
db_add_date <- function(tbl, time_col = "Observed_Date_Time", date_col = NULL) {
  date_col <- date_col %||% paste0("ren_", tolower(time_col))
  tbl <- dplyr::mutate(tbl, !!date_col := !!sql_get_date(time_col))
  tbl
}


#' Convert to date/time
#'
#' Identifies and converts character date/time fields to date time.
#'
#' @param tbl DuckDB tbl created with [renmods_connect()]
#'
#' @returns A `tbl_duckdb_connection` object - a lazy DuckDB table. With the
#' converted fields.
#'
#' @export

db_fmt_times <- function(tbl) {
  time_cols <- stringr::str_subset(colnames(tbl), "Time")
  tbl <- dplyr::mutate(tbl, ren_tz = !!sql_get_tz("Observed_Date_Time"))
  for (t in time_cols) {
    tbl <- dplyr::mutate(tbl, !!t := !!sql_get_time(t))
  }

  tbl
}

#' SQL command to return local date
#'
#' Creates SQL command to return the date of a time column according to the
#' local time zone of that time. I.e. extracts the date out of the character
#' string and converts to Date.
#'
#' @param col_name Character. Column/Field to return date from.
#'
#' @returns SQL Query
#'
#' @noRd
#' @examples
#' sql_get_date("Observed_Date_Time")

sql_get_date <- function(col_name) {
  dplyr::sql(paste0(
    "regexp_extract(",
    col_name,
    ", '\\d{4}-\\d{2}-\\d{2}')::DATE"
  ))
}

#' SQL command to return timezone
#'
#' Creates SQL command to return the timezone of a character time column.
#' Extracts out the timezone as text.
#'
#' @param col_name Character. Column/Field to return timezone from.
#'
#' @returns SQL Query
#'
#' @noRd
#' @examples
#' sql_get_tz("Observed_Date_Time")

sql_get_tz <- function(col_name) {
  dplyr::sql(paste0(
    "regexp_extract(",
    col_name,
    ", '(\\+|\\-)\\d{2}:\\d{2}$')"
  ))
}

#' SQL command to convert to date/time
#'
#' Creates SQL command to convert a column/field from character to date/time.
#'
#' @param col_name Character. Column/Field to convert.
#'
#' @returns SQL Query
#'
#' @noRd
#' @examples
#' sql_get_tz("Observed_Date_Time")

sql_get_time <- function(col_name) {
  dplyr::sql(paste0("STRPTIME(", col_name, ", '%Y-%m-%dT%H:%M%z')"))
}
