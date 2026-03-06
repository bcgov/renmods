# Get or create cache directory

Returns the path to the renmods cache directory. By default, creates the
directory if it doesn't exist (with user confirmation in interactive
mode). The cache location can be customized via the `renmods.cache_dir`
option.

## Usage

``` r
cache_dir(check_only = FALSE)
```

## Arguments

- check_only:

  Logical. If `TRUE`, only checks if cache directory exists without
  creating it or prompting user.

## Value

Character. Path to cache directory (when `check_only = FALSE`) or
logical indicating if cache exists (when `check_only = TRUE`).

## Examples

``` r
cache_dir(check_only = TRUE)
#> [1] FALSE
if (FALSE) { # \dontrun{
cache_dir()
} # }
```
