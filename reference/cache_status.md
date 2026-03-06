# View cache status

Returns information about cached ENMODS data including when each data
type was last downloaded, the date range it covers, and the file path.

## Usage

``` r
cache_status()
```

## Value

Data frame with columns:

- `type`: Data type (this_yr, yr_2_5, yr_5_10, historic)

- `last_downloaded`: Date/time of last download

- `date_range`: Date range covered by the data

- `renmods_version`: Package version used to download data

- `path`: File path to cached data

## Examples

``` r
# View status of all cached data
cache_status()
#> No cache
```
