# renmods v0.0.4

- Convert files to parquet for quicker loading
- Update to enforce duckdb v2.0.0
- Update date/time handling to match duckdb v2.0.0
- Add `result_type` argument to filter and convert `Result_Value`s to Numeric
  (by default), character, or both (with a warning about mixing types).
- Deprecate arguments `types` in favour of `datasets`

# renmods v0.0.3

- Fix `check_cache()` erroring if a download was interrupted

# renmods v0.0.2

- Fix times and timezones with new EnMoDS data version
- Export `extract_date_range()`

# renmods v0.0.1

- Initial creation of the package
