# Update cached ENMODS data

Downloads ENMODS data from BC Gov and saves to the local cache. By
default, only missing or outdated data is downloaded.

## Usage

``` r
renmods_update(types = "this_yr", force = FALSE)
```

## Arguments

- types:

  Character. Which data types to update. One or more of "this_yr",
  "yr_2_5", "yr_5_10", "historic", or "all" (default "this_yr").

- force:

  Logical. If `TRUE`, downloads data even if cache is up-to-date
  (default `FALSE`).

## Value

`NULL` invisibly. Called for side effect of downloading data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Update current year data
renmods_update()

# Update all data types
renmods_update("all")

# Force update of specific types
renmods_update(c("this_yr", "yr_2_5"), force = TRUE)
} # }
```
