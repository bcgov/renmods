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
