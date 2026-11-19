# Disconnect from the database

Disconnect from the database

## Usage

``` r
renmods_disconnect(tbl)
```

## Arguments

- tbl:

  DuckDB tbl created with
  [`renmods_connect()`](https://bcgov.github.io/renmods/reference/renmods_connect.md)

## Value

`NULL` invisibly. Called for side effect of disconnecting database.

## Examples

``` r
db <- renmods_connect()
#> ℹ Connecting to "this_yr", "yr_2_5", "yr_5_10", and "historic" data
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:25 (within 1 week(s))
#> ✔ yr_2_5: Last downloaded 2026-11-19 19:59:25 (within 26 week(s))
#> ✔ yr_5_10: Last downloaded 2026-11-19 19:59:25 (within 26 week(s))
#> ✔ historic: Last downloaded 2026-11-19 19:59:25 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
renmods_disconnect(db)
```
