[![img](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)

# renmods

An R package to download, import, and filter data from [B.C.’s
Environmental Monitoring Data
System](https://www2.gov.bc.ca/gov/content/environment/research-monitoring-reporting/monitoring/environmental-monitoring-data-system)
(EnMoDs) into R. ‘renmods’ package replaces ‘rems’ to support the new
data system released in March 2026.

The EnMoDs dataset is licensed under the [Open Government Licence -
British
Columbia](http://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61).

### Features

### Installation

``` r
# install.packages("devtools") # if not already installed

library(devtools)
```

    ## Loading required package: usethis

``` r
install_github("bcgov/renmods")
```

    ## WARNING: Rtools is required to build R packages, but no version of Rtools compatible with R 4.5.1 was found. (Only the following incompatible version(s) of Rtools were found: 4.4.6459)
    ## 
    ## Please download and install Rtools 4.5 from https://cran.r-project.org/bin/windows/Rtools/.

    ## Using GitHub PAT from the git credential store.

    ## Downloading GitHub repo bcgov/renmods@HEAD

    ## ── R CMD build ─────────────────────────────────────────────────────────────────

    ## WARNING: Rtools is required to build R packages, but no version of Rtools compatible with R 4.5.1 was found. (Only the following incompatible version(s) of Rtools were found: 4.4.6459)
    ## 
    ## Please download and install Rtools 4.5 from https://cran.r-project.org/bin/windows/Rtools/.

    ##       ✔  checking for file 'C:\Users\kharker\AppData\Local\Temp\RtmpkrLx1m\remotes48145a3a5ea0\bcgov-renmods-8d2942b/DESCRIPTION' (2s)
    ##       ─  preparing 'renmods': (399ms)
    ##    checking DESCRIPTION meta-information ...  ✔  checking DESCRIPTION meta-information
    ##       ─  checking for LF line-endings in source and make files and shell scripts (1.3s)
    ##   ─  checking for empty or unneeded directories
    ##       ─  building 'renmods_0.0.0.9000.tar.gz'
    ##      
    ## 

    ## Installing package into 'C:/Users/kharker/AppData/Local/R/win-library/4.5'
    ## (as 'lib' is unspecified)

### Usage

TBD

#### Example

TBD

``` r
## basic example code
```

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
