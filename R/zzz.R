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

.onLoad <- function(libname, pkgname) {
  # Set options
  opts <- list(
    renmods.cache_dir = NULL, # Not pre-set
    renmods.urls = list(
      "current" = "https://coms.api.gov.bc.ca/api/v1/object/84ed1220-bd51-40a8-9f29-d916144e2dfe",
      "yr_2_5" = "https://coms.api.gov.bc.ca/api/v1/object/6edecb56-d06a-4b2e-9ab0-48584eba3df0",
      "yr_5_10" = "https://coms.api.gov.bc.ca/api/v1/object/55e77e5a-ea9d-41e3-ab98-473fafabb0d6",
      "historic" = "https://coms.api.gov.bc.ca/api/v1/object/d88adc20-297e-4585-8de9-76a6342dd8e7"
    )
  )

  # Only set those not set by user
  options(opts[!names(opts) %in% names(options())])
}

renmods_types <- function() {
  c("current", "yr_2_5", "yr_5_10", "historic")
}
