# Test db_connect() ------------------------------------------------------------
test_that("db_connect() creates a DuckDB connection with extensions", {
  # Local installs expected to already have extension, but CI will not
  skip_on_local()
  expect_message(con <- db_connect(), "Installing DuckDB extension")
  expect_s4_class(con, "duckdb_connection")
  DBI::dbDisconnect(con)
})

test_that("db_connect() creates a DuckDB connection", {
  skip_on_ci() # Local install expect no messages
  expect_silent(con <- db_connect())
  expect_s4_class(con, "duckdb_connection")
  DBI::dbDisconnect(con)
})

test_that("db_connect() creates a DuckDB connection", {
  expect_message(con <- db_connect(), "duckdb is storing downloaded")
  expect_s4_class(con, "duckdb_connection")
  DBI::dbDisconnect(con)
})

test_that("db_connect() has httpfs extension available", {
  expect_message(con <- db_connect(), "duckdb is storing downloaded")

  # Check httpfs is loaded
  exts <- DBI::dbGetQuery(
    con,
    "SELECT extension_name FROM duckdb_extensions() WHERE loaded"
  )
  expect_true("httpfs" %in% exts$extension_name)

  DBI::dbDisconnect(con)
})


# Test renmods_connect() -------------------------------------------------------

test_that("renmods_connect() requires cached data", {
  withr::local_options(list(renmods.cache_dir = "temp"))

  expect_error(renmods_connect(), "No ENMODS data has been downloaded")
})

test_that("renmods_connect() & renmods_disconnect()", {
  skip_if_no_cache()

  expect_message(tbl <- renmods_connect(types = "historic"), "Connecting to") |>
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
  skip_if_no_cache()

  dates <- c("2010-01-01", "2010-01-31")
  expect_message(tbl <- renmods_connect(dates = dates)) |> suppressMessages()
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  renmods_disconnect(tbl)
})

test_that("renmods_connect() works with specific types", {
  skip_if_no_type("this_yr")

  expect_message(tbl <- renmods_connect(types = "this_yr")) |>
    suppressMessages()
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  renmods_disconnect(tbl)
})

test_that("renmods_connect() works with multiple types", {
  skip_if_no_cache()

  # Check at least two types exist
  status <- cache_status()
  available <- status$type[!is.na(status$path) & file.exists(status$path)]

  if (length(available) < 2) {
    skip("Need at least 2 cached data types for this test")
  }

  expect_message(
    tbl <- renmods_connect(types = available[1:2]),
    "Connecting"
  ) |>
    expect_message("Last downloaded") |>
    expect_message("Last downloaded")
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  renmods_disconnect(tbl)
})

test_that("renmods_connect() works with 'all' types", {
  skip_if_no_cache()

  expect_message(tbl <- renmods_connect(types = "all")) |> suppressMessages()
  expect_s3_class(tbl, "tbl_duckdb_connection")
  expect_rows(tbl)

  renmods_disconnect(tbl)
})
