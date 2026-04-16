# Convert to date/time

Identifies and converts character date/time fields to date time.

## Usage

``` r
db_fmt_times(tbl)
```

## Arguments

- tbl:

  DuckDB tbl created with
  [`renmods_connect()`](https://bcgov.github.io/renmods/reference/renmods_connect.md)

## Value

A `tbl_duckdb_connection` object - a lazy DuckDB table. With the
converted fields.
