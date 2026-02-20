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

check_type <- function(type) {
  t <- c("all", renmods_types())
  if (!type %in% t) {
    rlang::abort(
      paste0(
        "Type must be one of '",
        paste0(t, collapse = "', '"),
        "'"
      ),
      call = NULL
    )
  }
}

check_cache <- function(path, force) {
  # TODO: Check date

  if (!file.exists(path)) {
    update <- TRUE
  } else if (force) {
    update <- TRUE
    cli_alert_info("Forcing update of cached data")
  } else {
    update <- FALSE
  }

  update
}
