# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

**Read [CODE-DESIGN.md](../CODE-DESIGN.md) first.** It holds the human-facing
design notes (workflow, options, cache/download/db architecture, gotchas,
style). This file only adds agent-specific instructions and does not repeat it.

## What this is

`renmods` is an R package (bcgov) that downloads B.C. EnMoDS data as four large
`*.csv.gz` files (`this_yr`, `yr_2_5`, `yr_5_10`, `historic`) into a local cache
and exposes them as a lazy DuckDB table via `renmods_connect()`.

## Commands

Run from the package root. Always `devtools::load_all()` before running tests
from bash.

```bash
Rscript -e 'devtools::load_all(); devtools::test()'                 # all tests
Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-05-db.R")'  # one file
Rscript -e 'devtools::load_all(); devtools::test(filter = "cache")'  # by name
Rscript -e 'devtools::document()'   # regenerate man/ and NAMESPACE after roxygen edits
Rscript -e 'devtools::check()'
Rscript -e 'devtools::build_readme()'  # README.md is generated from README.Rmd
```

- Formatting uses the Air formatter (`air.toml`); `air format R tests` if `air`
  is installed.
- The full release checklist is in `RELEASE.R` (goodpractice, covr, spelling,
  urlchecker, pkgdown, rhub). Don't run the rhub/win-devel steps without asking.
- Vignettes in `vignettes/articles/` are precompiled: edit the `*.Rmd.orig`
  files, then run `source("vignettes/articles/precompile.R")` (requires real
  downloaded data). Never hand-edit the generated `*.Rmd`.

## Architecture notes that span files

- Data flow: `renmods_update()` → `check_cache()` (exists? forced? package
  version? age vs `renmods()$update`) → `renmods_update_()` (httr2 download) →
  `cache_meta(update = TRUE)` writes `metadata.csv` in the cache dir.
- `cache_meta(reset = TRUE)` is called *before* a download so an interrupted
  download leaves the dataset marked missing; `read_meta()` also blanks rows
  whose files have disappeared.
- Date ranges per dataset come from the original filename embedded in the gzip
  header (`extract_date_range()`); `which_datasets()` uses these to pick which
  files `renmods_connect(dates = ...)` reads.
- `renmods_connect()` builds a DuckDB `read_csv([...], union_by_name = true)`
  table function, adds `ren_date`, filters by date, then `db_fmt_times()`
  converts the character timestamps (with `-08:00` style offsets) using SQL from
  the `sql_*()` helpers. Output timezone is `Etc/GMT+7`; original offset is kept
  in `ren_tz`.
- Cache dir is `getOption("renmods.cache_dir")`, defaulting to
  `tools::R_user_dir("renmods", "data")` (not `"cache"`).
- Adding/changing a dataset means editing both the `renmods.urls` option and
  `renmods()` in `R/zzz.R`.

## Testing

- Never download real data in tests. Point the cache at a temp dir with
  `withr::local_tempdir()` + `withr::local_options(renmods.cache_dir = ...)` and
  mock with `local_mocked_bindings()` (e.g. `renmods_update_`, `check_cache`).
- `R/test-utils.R` defines `file.exists <- NULL` so base `file.exists()` can be
  mocked; keep it. Test helpers go in `R/test-utils.R`, not `helper.R`.
- Tests needing real cached data use `skip_if_no_cache()` /
  `skip_if_no_dataset()`; they only run locally. Confirm with the developer
  before running anything that hits the EnMoDs/COMS API.
- `ask()` always returns `TRUE` in tests (non-interactive), so prompts proceed.
- Test style: start with `expect_silent()` or `expect_message()`; prefer
  `expect_silent()` over `expect_invisible()`; use
  `expect_named(..., ignore.order = TRUE)`; test several values at once; don't
  prefix calls with `renmods::` / `renmods:::`.

## Code and documentation style

- Native pipe `|>`, `\(x)` lambdas, two-space indent, ~80 char lines.
- Messages/errors via cli (`cli_alert_*()`, `cli_abort(..., call = NULL)`); user
  prompts via the internal `ask()`.
- In dplyr/dbplyr verbs on the DuckDB table, unquote local values with `!!`.
- Roxygen2 with markdown. Argument docs start with a simple type then a period
  (`Character.`, `Logical.`, `Character vector.`, `Named list.`). If an argument
  is another function's output, say so. Return values with >4 named parts are a
  markdown list. Reference functions as `[fn()]`, arguments/fields in backticks.
  Internal functions use `@noRd`. Leave a blank uncommented line after the
  roxygen block.
- New R files carry the Apache 2.0 / Province of B.C. header used elsewhere.
