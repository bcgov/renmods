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
