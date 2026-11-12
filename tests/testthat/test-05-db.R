# Test db_connect() ------------------------------------------------------------
test_that("db_connect() creates a DuckDB connection with extensions", {
  # Local installs expected to already have extension, but CI will not
  skip_on_local()
  expect_message(con <- db_connect(), "Installing DuckDB extension")
  expect_s4_class(con, "duckdb_connection")
  DBI::dbDisconnect(con) # Clean up
})

test_that("db_connect() creates a DuckDB connection - Local only", {
  skip_on_ci() # Local install expect no messages
  testthat::capture_messages(con <- db_connect())
  expect_s4_class(con, "duckdb_connection")
  DBI::dbDisconnect(con) # Clean up
})

test_that("db_connect() creates a DuckDB connection", {
  expect_message(con <- db_connect(), "duckdb (is storing|keeps) downloaded")
  expect_s4_class(con, "duckdb_connection")
  DBI::dbDisconnect(con) # Clean up
})

test_that("db_connect() has httpfs extension available", {
  expect_message(con <- db_connect(), "duckdb (is storing|keeps) downloaded")

  # Check httpfs is loaded
  exts <- DBI::dbGetQuery(
    con,
    "SELECT extension_name FROM duckdb_extensions() WHERE loaded"
  )
  expect_true("httpfs" %in% exts$extension_name)

  # Clean up
  DBI::dbDisconnect(con)
})


# Test renmods_connect() -------------------------------------------------------

test_that("renmods_connect() requires cached data", {
  withr::local_options(list(renmods.cache_dir = "temp"))

  expect_error(renmods_connect(), "No EnMoDS data has been downloaded")
})

test_that("renmods_connect() & renmods_disconnect()", {
  op <- use_example_cache() # Use example cache in temp folder
  withr::defer(options(op))

  expect_message(
    tbl <- renmods_connect(datasets = "historic"),
    "Connecting to"
  ) |>
    expect_message("Last downloaded")
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  # Check it has expected columns
  cols <- colnames(tbl)
  expect_true("Location_ID" %in% cols)
  expect_true("Observed_Date_Time" %in% cols)

  # Closes down the connection
  expect_silent(renmods_disconnect(tbl))
  expect_warning(renmods_disconnect(tbl), "Connection already closed")
})

test_that("renmods_connect() filters by date range", {
  op <- use_example_cache() # Use example cache in temp folder
  withr::defer(options(op))

  dates <- c("2010-01-01", "2017-12-31")
  expect_message(tbl <- renmods_connect(dates = dates)) |> suppressMessages()
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)
  dts <- collect(tbl) |> dplyr::pull(ren_date)
  expect_gte(min(dts), dates[1])
  expect_lte(max(dts), dates[2])

  # Clean up
  renmods_disconnect(tbl)
})

test_that("renmods_connect() works with specific datasets", {
  op <- use_example_cache() # Use example cache in temp folder
  withr::defer(options(op))

  expect_message(tbl <- renmods_connect(datasets = "this_yr")) |>
    suppressMessages()
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  # Clean up
  renmods_disconnect(tbl)
})

test_that("renmods_connect() works with multiple datasets", {
  op <- use_example_cache() # Use example cache in temp folder
  withr::defer(options(op))

  # Check at least two datasets exist
  status <- cache_status()
  available <- status$dataset[!is.na(status$path) & file.exists(status$path)]

  expect_message(
    tbl <- renmods_connect(datasets = available[1:2]),
    "Connecting"
  ) |>
    expect_message("Last downloaded") |>
    expect_message("Last downloaded")
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  # Clean up
  renmods_disconnect(tbl)
})

test_that("renmods_connect() works with 'all' datasets", {
  op <- use_example_cache() # Use example cache in temp folder
  withr::defer(options(op))

  expect_message(tbl <- renmods_connect(datasets = "all")) |> suppressMessages()
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  # Clean up
  renmods_disconnect(tbl)
})

test_that("renmods_connect() deprecate types", {
  op <- use_example_cache() # Use example cache in temp folder
  withr::defer(options(op))

  expect_message(
    tbl <- renmods_connect(types = "this_yr"),
    "`types` has been deprecated"
  ) |>
    suppressMessages()

  # Clean up
  renmods_disconnect(tbl)
})
