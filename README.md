
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![R-CMD-check](https://github.com/steffilazerte/renmods/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/steffilazerte/renmods/actions/workflows/R-CMD-check.yaml)
[![Code Coverage:
83%](https://img.shields.io/badge/code_coverage-83%25-green)](#code-coverage)
<!-- badges: end -->

# renmods

An R package to download, import, and filter data from [B.C.’s
Environmental Monitoring Data
System](https://www2.gov.bc.ca/gov/content/environment/research-monitoring-reporting/monitoring/environmental-monitoring-data-system)
(EnMoDs) into R. The ‘renmods’ package replaces ‘rems’ to support the
new data system released in March 2026.

The EnMoDs dataset is licensed under the [Open Government Licence -
British
Columbia](https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61).

### Features

- Download ENMODS data and cache locally
- Simple connections to the ENMODS database, only to as much data as
  required to speed up load times.

### Installation

``` r
# install.packages("pak") # if not already installed

library(pak)
pkg_install("bcgov/renmods")
```

### Usage

See the [Get
Started](https://steffilazerte.github.io/renmods/articles/renmods.html)
tutorial for details

### Project Status

Very first stages of development.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/renmods/issues/).

### How to Contribute

If you would like to contribute to the package, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## Code Coverage

    #> renmods Coverage: 83.09%
    #> R/checks.R: 62.11%
    #> R/db.R: 88.33%
    #> R/cache.R: 89.19%
    #> R/utils.R: 89.19%
    #> R/db_utils.R: 100.00%
    #> R/download.R: 100.00%
    #> R/test-utils.R: 100.00%
    #> R/zzz.R: 100.00%

### License

    Copyright 2026 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

------------------------------------------------------------------------

*This project was created using the
[bcgovr](https://github.com/bcgov/bcgovr) package.*
