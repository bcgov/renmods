# Update cached EnMoDS data

Downloads EnMoDS data from BC Gov and saves to the local cache. By
default, only missing or outdated data is downloaded.

## Usage

``` r
renmods_update(
  datasets = "this_yr",
  force = FALSE,
  cleanup = TRUE,
  types = NULL
)
```

## Arguments

- datasets:

  Character. Which datasets to update. One or more of "this_yr",
  "yr_2_5", "yr_5_10", "historic", or "all" (default "this_yr").

- force:

  Logical. If `TRUE`, downloads data even if cache is up-to-date
  (default `FALSE`).

- cleanup:

  Logical. Whether to remove the downloaded `csv.gz` file(s) after
  conversion to parquet. Defaults to TRUE.

- types:

  Character. Deprecated, use `datasets` instead.

## Value

`NULL` invisibly. Called for side effect of downloading data.

## Examples

``` r
if (FALSE) { # \dontrun{
# Update current year data
renmods_update()

# Update all datasets
renmods_update("all")

# Force update of specific datasets
renmods_update(c("this_yr", "yr_2_5"), force = TRUE)
} # }
```
