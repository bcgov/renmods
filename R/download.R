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

#' Title
#'
#' @param type
#'
#' @returns
#'
#' @export
#' @examplesIf interactive()
#' renmods_update()
#' renmods_update("all")

renmods_update <- function(type = "current", force = FALSE) {
  check_type(type)

  # Repeat for all if requested
  if (type == "all") {
    purrr::walk(renmods_types(), \(t) renmods_update(t, force = force))
    return(invisible())
  }
  path <- cache_path(type)
  url <- getOption("renmods.urls")[[type]]

  cli_par()
  cli_alert("Downloading '{type}' data from ENMODS")

  if (check_cache(path, force)) {
    cli_alert_info("Saving to cache: {path}")

    httr2::request(url) |>
      httr2::req_progress() |>
      httr2::req_perform(path = path)

    cli_alert_success("Data '{type}' successfully downloaded")
  } else {
    cli_alert_success("Data '{type}' already present and up-to-date")
  }
}
