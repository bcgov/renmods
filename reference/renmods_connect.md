# Connect to EnMoDS data via DuckDB

Creates a DuckDB connection to cached EnMoDS Parquet data. The database
table can be filtered using dplyr before collecting into a data frame
with
[`collect()`](https://bcgov.github.io/renmods/reference/collect.md).
Using `dates` (date range) or `datasets` prefilters the data to a
specific date range or specific data file. But if both are supplied,
`dates` takes precedence. Only the data files required will be connected
to and the fewer data sources connected to and the smaller the dataset,
the quicker the
[`collect()`](https://bcgov.github.io/renmods/reference/collect.md)
function will run.

## Usage

``` r
renmods_connect(
  dates = NULL,
  datasets = "all",
  result_type = "numeric",
  convert_times = TRUE,
  tz_disp = "Etc/GMT+7",
  types = NULL
)
```

## Arguments

- dates:

  Character or Date vector of length 2. Start and end dates for
  filtering data ("YYYY-MM-DD"). Note that data is filtered by the
  `Observed_Date_Time` field.

- datasets:

  Character. Datasets to connect to. One or more of "this_yr", "yr_2_5",
  "yr_5_10", "historic", or "all" (default "all"). Ignored if `dates` is
  specified.

- result_type:

  Character. Which types of results to return, "numeric" (default),
  "non-numeric", or "all" (not recommended). If "numeric",
  `Result_Value` is converted to numeric, otherwise left as character.
  Result types are based on the value of
  `Observed_Property_Result_Type`.

- convert_times:

  Logical. Whether or not to convert character date/times to date/time
  format in R. Defaults to `TRUE`. If `FALSE` remain as character.

- tz_disp:

  Character. Timezone in which to display the data. Default is Etc/GMT+7
  (i.e. UTC-7). Must be valid timezone from
  [`OlsonNames()`](https://rdrr.io/r/base/timezones.html).

- types:

  Character. Deprecated, use `datasets` instead.

## Value

A `tbl_duckdb_connection` object - a lazy DuckDB table. Use dplyr
functions to filter/select, then
[`collect()`](https://bcgov.github.io/renmods/reference/collect.md) to
load into R memory.

## Details

Note that EnMoDS stores date/times as character/text fields with the
timezone indicated by +/- offset (e.g., '-08:00'). However, in R all
values in a column must use the same timezone. Therefore times are
converted to UTC-7:00 (called `Etc/GMT+7`, note that `+` is correct; see
the [Wikipedia page on
timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)).
The original timezone from `Observed_Date_Time` is stored in a new field
`ren_tz` for reference. You can convert to any timezone using the
[`lubridate::with_tz()`](https://lubridate.tidyverse.org/reference/with_tz.html)
function.

## Examples

``` r


# All data
db <- renmods_connect()
#> ℹ Connecting to "this_yr", "yr_2_5", "yr_5_10", and "historic" data
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:21 (within 1 week(s))
#> ✔ yr_2_5: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ yr_5_10: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ historic: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
#> ℹ Installing DuckDB extension 'httpfs'
#> ℹ Installing DuckDB extension 'icu'

# Use dplyr to filter and manipulate the data
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

# Filter and collect into a data frame
df <- renmods_connect() |>
  filter(Location_ID %in% c("E327371", "E300230")) |>
  collect()
#> ℹ Connecting to "this_yr", "yr_2_5", "yr_5_10", and "historic" data
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:21 (within 1 week(s))
#> ✔ yr_2_5: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ yr_5_10: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ historic: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

# Automatically connects only to datasets required for a specific date range
db <- renmods_connect(dates = c("2025-01-01", "2025-02-01"))
#> ℹ Connecting to "this_yr" data for dates between 2025-01-01 and 2025-02-01
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:21 (within 1 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
db <- renmods_connect(dates = c("1990-01-01", "1990-02-01"))
#> ℹ Connecting to "historic" data for dates between 1990-01-01 and 1990-02-01
#> ✔ historic: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

# By default, only returns data where Observed_Property_Result_Type is NUMERIC
# But you can specify non-numeric data
db <- renmods_connect(result_type = "non-numeric")
#> ℹ Connecting to "this_yr", "yr_2_5", "yr_5_10", and "historic" data
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:21 (within 1 week(s))
#> ✔ yr_2_5: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ yr_5_10: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ historic: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
select(db, "Observed_Property_ID", "Result_Value")
#> # A query:  ?? x 2
#> # Database: DuckDB 2.0.0 [unknown@Linux 7.0.0-1020-azure:R 4.6.2/:memory:]
#> # ℹ 2 variables: Observed_Property_ID <chr>, Result_Value <chr>

# Or even *all* data
# Note: This will result in a mix of numeric and non-numeric and
#  Result_Value will be "character"
db <- renmods_connect(result_type = "all")
#> ℹ Connecting to "this_yr", "yr_2_5", "yr_5_10", and "historic" data
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:21 (within 1 week(s))
#> ✔ yr_2_5: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ yr_5_10: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ historic: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.
#> Warning: Using `result_type = 'all'` means that 'Result_Values' may be a combination of
#> numeric, categorical, and/or character values
select(db, "Observed_Property_ID", "Result_Value")
#> # A query:  ?? x 2
#> # Database: DuckDB 2.0.0 [unknown@Linux 7.0.0-1020-azure:R 4.6.2/:memory:]
#>    Observed_Property_ID                        Result_Value
#>    <chr>                                       <chr>       
#>  1 Potassium Dissolved (fl. conc.)             0.12        
#>  2 Cobalt Total (fl. conc.)                    2.2E-5      
#>  3 Potassium Total (fl. conc.)                 0.125       
#>  4 Manganese Total (fl. conc.)                 0.00115     
#>  5 Aluminum Dissolved (fl. conc.)              0.026       
#>  6 Cobalt Dissolved (fl. conc.)                1.6E-5      
#>  7 Alkalinity Total 4.5 (as CaCO3) (fl. conc.) 13.0        
#>  8 Beryllium Dissolved (fl. conc.)             1.5E-5      
#>  9 pH-Field (acidity)                          7.68        
#> 10 Calcium Total (fl. conc.)                   9.34        
#> # ℹ more rows

# Explore the data and column names
colnames(db)
#>  [1] "Location_ID"                   "Location_Name"                
#>  [3] "Observed_Property_ID"          "Observed_Property_Name"       
#>  [5] "Observed_Property_Result_Type" "Observed_Date_Time"           
#>  [7] "Analysis_Method_ID"            "Result_Value"                 
#>  [9] "Result_Unit"                   "Result_Status"                
#> [11] "Result_Grade"                  "ren_date"                     
#> [13] "filename"                      "ren_tz"                       
glimpse(db)
#> Rows: ??
#> Columns: 14
#> $ Location_ID                   <chr> "Location1", "Location1", "Location1", "…
#> $ Location_Name                 <chr> "Example Location no.1", "Example Locati…
#> $ Observed_Property_ID          <chr> "Potassium Dissolved (fl. conc.)", "Coba…
#> $ Observed_Property_Name        <chr> "K--D", "CO-T", "K--T", "MN-T", "AL-D", …
#> $ Observed_Property_Result_Type <chr> "NUMERIC", "NUMERIC", "NUMERIC", "NUMERI…
#> $ Observed_Date_Time            <dttm> 2025-04-14 10:06:00, 2025-04-14 10:06:0…
#> $ Analysis_Method_ID            <chr> "F032", "F121", "F121", "F121", "F032", …
#> $ Result_Value                  <chr> "0.12", "2.2E-5", "0.125", "0.00115", "0…
#> $ Result_Unit                   <chr> "mg/L", "mg/L", "mg/L", "mg/L", "mg/L", …
#> $ Result_Status                 <chr> "Preliminary", "Preliminary", "Prelimina…
#> $ Result_Grade                  <chr> "Ungraded", "Ungraded", "Ungraded", "Ung…
#> $ ren_date                      <date> 2025-04-14, 2025-04-14, 2025-04-14, 202…
#> $ filename                      <chr> "/tmp/Rtmp9KsHTM/renmods_cache/this_yr.p…
#> $ ren_tz                        <chr> "-08:00", "-08:00", "-08:00", "-08:00", …

# Filter and collect specific data
df <- renmods_connect() |>
  filter(Location_ID %in% c("E327371", "E300230")) |>
  select(
    "Location_ID", "Location_Name", "Observed_Date_Time",
    "Observed_Property_Name", "Result_Value", "Result_Unit",
    "Analysis_Method_ID"
  ) |>
  collect()
#> ℹ Connecting to "this_yr", "yr_2_5", "yr_5_10", and "historic" data
#> ✔ this_yr: Last downloaded 2026-11-19 19:59:21 (within 1 week(s))
#> ✔ yr_2_5: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ yr_5_10: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> ✔ historic: Last downloaded 2026-11-19 19:59:21 (within 26 week(s))
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp9KsHTM/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

# Remember to shut down the connection when you're done
renmods_disconnect(db)
```
