# Create small test data sets from real downloaded data

download_csv("this_yr")

test_data_path <- file.path(testthat::test_path(
  "fixtures",
  "20250101_to_20261107.csv"
))
lines <- readLines(gzfile(cache_path("this_yr")), n = 5)
writeLines(lines, test_data_path)
system2(
  "gzip",
  c("-c", test_data_path),
  stdout = testthat::test_path("fixtures", "this_year.csv.gz")
)

# Clean up
unlink(test_data_path)
unlink(cache_path("this_yr"))
