# Test renmods_update() -------------------------------------------------------

test_that("renmods_update() validates datasets", {
  expect_error(renmods_update("invalid_data"), "`datasets` must be one of")
})

test_that("renmods_update() skips when data is up-to-date", {
  # Pretend cache is fine
  local_mocked_bindings(check_cache = \(dataset, force) FALSE)

  expect_message(
    renmods_update("this_yr"),
    "already present and up-to-date"
  )
})

test_that("renmods_update() calls renmods_update_ for each dataset when 'all'", {
  # Mock renmods_update_ to avoid actual downloads
  local_mocked_bindings(renmods_update_ = \(dataset, cleanup) {
    cli_alert_success("Mocked download for {dataset}")
  })

  # Mock check_cache to return TRUE (needs update)
  local_mocked_bindings(check_cache = \(dataset, force) TRUE)

  expect_message(renmods_update("all"), "Mocked download") |>
    expect_message("Mocked download") |>
    expect_message("Mocked download") |>
    expect_message("Mocked download")
})

test_that("renmods_update() respects force argument", {
  # Create file so would normally check date
  temp_dir <- withr::local_tempdir()
  withr::local_options(list(renmods.cache_dir = temp_dir))
  temp_file <- writeLines("test", file.path(temp_dir, "this_yr.parquet"))

  # Mock renmods_update_ to avoid actual downloads
  local_mocked_bindings(renmods_update_ = \(dataset, cleanup) {
    cli_alert_success("Mocked download for {dataset}")
  })

  expect_message(renmods_update("this_yr", force = TRUE), "Forcing update") |>
    expect_message("Mocked download")
})


# Test renmods_update_() -------------------------------------------------------

test_that("renmods_update_() downloads and updates metadata", {
  withr::local_options(list(renmods.cache_dir = withr::local_tempdir()))

  # Mock httr2 request/perform to avoid actual download
  local_mocked_bindings(
    req_progress = \(req) req,
    req_perform = \(req, path) {
      # Create a fake gzip file with proper header
      con <- gzfile(path, "w")
      writeLines(
        c(
          "Location_ID,Observed_Date_Time,Result_Value",
          "XXXX,2025-12-15T17:25-08:00,101"
        ),
        con
      )
      close(con)
      structure(list(), class = "httr2_response")
    },
    .package = "httr2" # Not recommended, but should be safe here
  )

  expect_message(renmods_update_("this_yr"), "Updating") |>
    suppressMessages()
  expect_message(renmods_update_("this_yr"), "Successfully downloaded") |>
    suppressMessages()

  # Verify file was created
  expect_true(file.exists(cache_path("this_yr", "parquet")))

  # Verify metadata was updated
  meta <- cache_meta(datasets = "this_yr")
  expect_false(is.na(meta$last_downloaded))
})
