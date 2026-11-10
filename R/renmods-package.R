# Copyright 2026 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

#' @keywords internal
"_PACKAGE"

#' @section Package options:
#'
#' The following options control package behavior:
#'
#' \describe{
#'   \item{\code{renmods.cache_dir}}{Directory for caching downloaded data.
#'     Default: \code{NULL} (uses \code{tools::R_user_dir("renmods", "cache")}).
#'     Set to a custom path to override default location.}
#'   \item{\code{renmods.urls}}{Named list of URLs for EnMoDS data sources.
#'     Contains: \code{this_yr}, \code{yr_2_5}, \code{yr_5_10}, and
#'     \code{historic}. URLs are provided by default but can be overridden.}
#' }
#'
#' Set options using \code{options()}, for example:
#' \preformatted{
#' options(renmods.cache_dir = "~/.renmods_cache")
#' }
#'
#' @section Data types:
#'
#' The package provides access to four data types covering different time periods:
#'
#' \describe{
#'   \item{\code{this_yr}}{Current year data (updates weekly)}
#'   \item{\code{yr_2_5}}{Data from 2-5 years ago (updates every 26 weeks)}
#'   \item{\code{yr_5_10}}{Data from 5-10 years ago (updates every 26 weeks)}
#'   \item{\code{historic}}{Data older than 10 years (updates every 26 weeks)}
#' }

## usethis namespace: start
#' @importFrom cli cli_abort
#' @importFrom cli cli_alert
#' @importFrom cli cli_alert_info
#' @importFrom cli cli_alert_success
#' @importFrom cli cli_alert_warning
#' @importFrom cli cli_inform
#' @importFrom cli cli_par
#' @importFrom cli cli_ul
#' @importFrom cli cli_warn
#' @importFrom rlang .data
#' @importFrom rlang .env
## usethis namespace: end
NULL
