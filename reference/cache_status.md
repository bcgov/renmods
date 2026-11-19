# View cache status

Returns information about cached EnMoDS data including when each dataset
was last downloaded, the date range it covers, and the file path.

## Usage

``` r
cache_status()
```

## Value

Data frame with columns:

- `dataset`: Dataset (this_yr, yr_2_5, yr_5_10, historic)

- `last_downloaded`: Date/time of last download

- `date_range`: Date range covered by the data

- `renmods_version`: Package version used to download data

- `path`: File path to cached data

## Examples

``` r
# View status of all cached data
cache_status()
#> No cache

# After download
cache_status()
#> # A tibble: 4 × 5
#>   dataset  last_downloaded     date_range               renmods_version path    
#>   <chr>    <chr>               <chr>                    <chr>           <chr>   
#> 1 this_yr  2026-11-19 19:59:20 2025-01-01 to 2026-11-07 0.0.4           /tmp/Rt…
#> 2 yr_2_5   2026-11-19 19:59:20 2022-01-01 to 2024-12-31 0.0.4           /tmp/Rt…
#> 3 yr_5_10  2026-11-19 19:59:20 2017-01-01 to 2021-12-31 0.0.4           /tmp/Rt…
#> 4 historic 2026-11-19 19:59:20 2016-12-31               0.0.4           /tmp/Rt…
```
