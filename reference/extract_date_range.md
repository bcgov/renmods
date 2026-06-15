# Extract date range from gzip file metadata

Reads the gzip file header to extract the original filename, then parses
the date range from the filename (expected format: YYYYMMDD).

## Usage

``` r
extract_date_range(path)
```

## Arguments

- path:

  Character. Path(s) to gzip file(s).

## Value

Character. Date range in format "YYYY-MM-DD to YYYY-MM-DD" or character
vector if multiple paths provided.

## References

- https://www.rfc-editor.org/rfc/rfc1952.html#page-5

- https://en.wikipedia.org/wiki/Gzip#File_structure

## Examples

``` r
if (FALSE) { # interactive()
extract_date_range(cache_path("this_yr"))
extract_date_range(cache_path("yr_2_5"))
extract_date_range(cache_path("yr_5_10"))
extract_date_range(cache_path("historic"))

extract_date_range(cache_path(c("this_yr", "historic")))
}
```
