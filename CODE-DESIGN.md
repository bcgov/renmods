# Code Design

## Be careful
- Is the update frequency in `renmods()$update` appropriate?
- `cache_meta()` uses `extract_date_range()` to pull the original file name from the 
  downloaded `*.csv.gz`. Currently that is a date range for the file, which is how 
  we get the date ranges of different data sets. However, if the file names change this might break.
- Note the custom `ask()` function which always returns `TRUE` if in a non-interactive session.
- The `ask()` function also uses `rlang::is_interactive()` which works better with testthat (always assumes 'FALSE' in tests)
- Current data types are: `this_yr`, `yr_2_5`, `yr_5_10`, `historic`
    - If these change, modify `zzz.R` - `renmods.urls` option and types in `renmods()$types`

## Future ideas
- Is it possible to download in parallel with [furrr](https://furrr.futureverse.org/)
- Are there likely to be data versions for ENMODS? Is tracking the last date of download and the date range of the files sufficient to track this?
- Right now the actual `renmods_connect()` tests are skipped if there is no locally downloaded data in the cache, but we could consider mocking a db for this (see https://docs.ropensci.org/dittodb/)

## Style
- Use R version >= 4.1 with native pipe (`|>`) and `\(x)` anonymous functions
- Try to always check inputs at the top of a function
- Use Air formatter (`air.toml` and for Positron, `.vscode/*`
    - Setup in [RStudio](https://posit-dev.github.io/air/editor-rstudio.html)
    - Prebundled in [Positron](https://posit-dev.github.io/air/editor-vscode.html)
- Use [cli](https://cli.r-lib.org/) for messages/errors
- Try to avoid downloading data in tests
    - use `local_mocked_bindings()` to mock
    - Includes several tests which can only be run locally, use `skip_if_no_cache()`

## Gotchas
- When using expressions/variables in dplyr/dbplyr functions manipulating a database, 
  must use the bang-bang (`!!`) to unquote the expression and ensure it is
  evaluated before being passed on.
- Users are forced to update their data if it was downloaded with an older 
  version of the package. This is to ensure that if the data changes, and the
  package changes to match, that users don't get funny errors if they try to 
  use older versions of the data with a newer version of the package. If
  ENMODS has a data versioning system, we could use that instead.

## Workflow
The workflow is hopefully very simple: 

- `renmods_update()` - Download and cache data locally
- `renmods_connect()` - Connect to *.csv.gz files
- `collect()` - Retrieve data to R data.frame/tibble (reexported from dplyr)
- `renmods_disconnect()` - Disconnect from the data base

There are also a family of `cache_xxx()` functions for controlling the cache.


## Options (`zzz.R`)
- Options are set in `zzz.R` via `.onLoad()`
- Options include: 
    - `renmods.cache_dir`: Where to store downloaded data (defaults to `NULL`)
    - `renmods.urls`: URLs for four data types 
- Options are only set if they aren't already present

## Internal data via functions (`zzz.R`)
- `renmods()` is an internal function (in `zzz.R`) that lists
  - Data types available ('this_yr', 'yr_2_5', 'yr_5_10', 'historic')
  - Update intervals (in weeks) for each type
- This could be a data set, but I don't think it needs to be

## Cache (`cache.R`)
- Cache functions are in `cache.R`
- Users can see 
  - `cache_dir()` (checks and creates directory)
  - `cache_status()` (returns data frame of cached files, download dates, date ranges, and file paths)
  - `cache_remove()` (remove parts or whole of cache)
- `cache_path()` and `cache_meta()` are internal
  - `cache_meta()` is very similar to `cache_status()` but is also used to update/reset the cache metadata.
  - `cache_meta()` uses `extract_date_range()` to pull the original file name from the 
  downloaded `*.csv.gz`. Currently that is a date range for the file, but if the file names change this might break.
- Cache functions are meant to check for cache, create cache and prompt updates as needed. 
  It is sometimes a bit convoluted and they are extremely chatty, so it might be worth adding silencing options in future


## Downloads (`download.R`)
- Downloads shouldn't redownload data unless `force = TRUE` if the data is a) present and b) within so many weeks of having been updated (see `renmods()$update`)
- Use `renmods_update_()` as an internal function so we can download out of date/missing data when the `renmods_connect()` function is used without all the chatter.

## Database (`db.R`)
- `renmods_connect()` combines and connects to all data by default
- Users can supply a date range or the data type they wish to connect to
- For a date range, we check the metadata and pick only the data types needed,
  then we prefilter the data by date.
- `collect()` is exported from dplyr (`re-exports.R`) so that users don't have
  to use dplyr just to get the data.

## Database Utility functions (`db_utils.R`)
- `db_xx()` and `sql_xx()` functions to make modifications to the database,
  namely times and dates
- `sql_xx()` merely create the SQL expressions required

## Other
- Standard checks are in `checks.R`
- Test utiliity functsion are in `test-utils.R`
- Random utility functions are in `utils.R`
    - One thing to note is that we have a custom `ask()` function which always
    returns `TRUE` if in a non-interactive session.