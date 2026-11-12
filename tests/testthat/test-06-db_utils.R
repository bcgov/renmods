test_that("db_fmt_times()", {
  op <- use_example_cache() # Use example cache in temp folder

  # Check a random sample of 50 dates per timezone

  tz <- renmods_connect(types = "all", convert_times = FALSE) |>
    dplyr::mutate(
      tz = !!sql_get_tz("Observed_Date_Time"),
      time = !!sql_get_time("Observed_Date_Time")
    ) |>
    dplyr::select("Observed_Date_Time", "time", "tz") |>
    dplyr::slice_sample(n = 50, by = "tz") |>
    dplyr::collect() |>
    dplyr::mutate(
      lubridate = lubridate::parse_date_time(
        .data$Observed_Date_Time,
        "Ymd HMz",
        tz = "Etc/GMT+7"
      )
    ) |>
    suppressMessages()

  expect_equal(tz$time, tz$lubridate)

  # Clean up
  options(op) # Reset cache location
})
