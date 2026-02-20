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
