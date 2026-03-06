# Disconnect from the database

Disconnect from the database

## Usage

``` r
renmods_disconnect(tbl)
```

## Arguments

- tbl:

  DuckDB tbl created with
  [`renmods_connect()`](http://steffilazerte.ca/renmods/reference/renmods_connect.md)

## Value

`NULL` invisibly. Called for side effect of disconnecting database.

## Examples

``` r
if (FALSE) { # interactive()
db <- renmods_connect()
renmods_disconnect(db)
}
```
