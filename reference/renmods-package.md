# renmods: Download and query data from B.C. Environmental Monitoring Data System (EnMoDs)

Downloads and queries data from B.C. Environmental Monitoring Data
System (EnMoDs).

## Package options

The following options control package behavior:

- `renmods.cache_dir`:

  Directory for caching downloaded data. Default: `NULL` (uses
  `tools::R_user_dir("renmods", "cache")`). Set to a custom path to
  override default location.

- `renmods.urls`:

  Named list of URLs for EnMoDS data sources. Contains: `this_yr`,
  `yr_2_5`, `yr_5_10`, and `historic`. URLs are provided by default but
  can be overridden.

Set options using [`options()`](https://rdrr.io/r/base/options.html),
for example:


    options(renmods.cache_dir = "~/.renmods_cache")

## Datasets

The package provides access to four EnMoDS datasets covering different
time periods:

- `this_yr`:

  Current year data (updates weekly)

- `yr_2_5`:

  Data from 2-5 years ago (updates every 26 weeks)

- `yr_5_10`:

  Data from 5-10 years ago (updates every 26 weeks)

- `historic`:

  Data older than 10 years (updates every 26 weeks)

## See also

Useful links:

- <https://github.com/bcgov/renmods>

- <https://bcgov.github.io/renmods/>

- Report bugs at <https://github.com/bcgov/renmods/issues>

## Author

**Maintainer**: Karly Harker <karly.harker@gov.bc.ca> \[contributor\]

Authors:

- Steffi LaZerte <sel@steffilazerte.ca>
  ([ORCID](https://orcid.org/0000-0002-7690-8360))

Other contributors:

- Province of British Columbia \[copyright holder\]
