# Connect to ENMODS data via DuckDB

Creates a DuckDB connection to cached ENMODS data. The database table
can be filtered using dplyr before collecting into a data frame with
[`collect()`](http://steffilazerte.ca/renmods/reference/collect.md).
Using `dates` (date range) or `types` (data types) prefilters the data
to a specific date range or specific data file. But if both are
supplied, `dates` takes precedence. Only the data files required will be
connected to and the fewer data sources connected to and the smaller the
dataset, the quicker the
[`collect()`](http://steffilazerte.ca/renmods/reference/collect.md)
function will run.

## Usage

``` r
renmods_connect(dates = NULL, types = "all")
```

## Arguments

- dates:

  Character or Date vector of length 2. Start and end dates for
  filtering data ("YYYY-MM-DD"). Note that data is filtered by the
  `Observed_Date_Time` field.

- types:

  Character. Data types to connect to. One or more of "this_yr",
  "yr_2_5", "yr_5_10", "historic", or "all" (default "all"). Ignored if
  `dates` is specified.

## Value

A `tbl_duckdb_connection` object - a lazy DuckDB table. Use dplyr
functions to filter/select, then
[`collect()`](http://steffilazerte.ca/renmods/reference/collect.md) to
load into R memory.

## Examples

``` r
if (FALSE) { # interactive()
# All data
db <- renmods_connect()

# All current data
db <- renmods_connect(types = "this_yr")

# Connect only to data types required for a specific date range
db <- renmods_connect(dates = c("2025-01-01", "2025-02-01"))

# Use dplyr to manipulate the data
library(dplyr)

# Explore the data and column names
colnames(db)
glimpse(db)

# Filter and collect specific data
df <- db |>
  filter(Location_ID %in% c("E327371", "E300230")) |>
  select(
    "Location_ID", "Location_Name", "Observed_Date_Time",
    "Observed_Property_Name", "Result_Value", "Result_Unit",
    "Analysis_Method_ID"
  ) |>
  collect()

# Remember to shut down the connection when you're done
renmods_disconnect(db)
}
```
