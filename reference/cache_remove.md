# Remove cached data

Deletes cached ENMODS data files. Use with caution as this will require
re-downloading data. In interactive mode, prompts for confirmation
before deletion.

## Usage

``` r
cache_remove(types = "all")
```

## Arguments

- types:

  Character. Which data types to remove. Either "all" (default) to
  remove all cached data and the cache directory, or one or more of
  "this_yr", "yr_2_5", "yr_5_10", "historic".

## Value

`TRUE` invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
# Remove all cached data
cache_remove()

# Remove specific data types
cache_remove(types = c("this_yr", "yr_2_5"))

# Remove just historic data
cache_remove(types = "historic")
} # }
```
