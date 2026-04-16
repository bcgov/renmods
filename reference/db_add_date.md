# Create new field with local date

Converts a time/date column to just local date (i.e. truncates the time
and converts to date).

## Usage

``` r
db_add_date(tbl, time_col = "Observed_Date_Time", date_col = NULL)
```

## Arguments

- tbl:

  DuckDB tbl created with
  [`renmods_connect()`](https://bcgov.github.io/renmods/reference/renmods_connect.md)

- time_col:

  Character. Field/Column name for date/time column from which to
  extract a date.

- date_col:

  Character. Name of the new field/column to create.

## Value

A `tbl_duckdb_connection` object - a lazy DuckDB table. With the
additional field.
