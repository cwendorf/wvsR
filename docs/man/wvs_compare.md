# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Compare means for two countries side-by-side

### Description

Compute mean scores and confidence intervals for each dimension separately for two countries, returning results suitable for side-by-side plotting.

### Usage

```r
wvs_compare(
  countries,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  ci_level = 0.95,
  max_points = 1500,
  seed = NULL,
  path = NULL
)
```

### Arguments

- `countries`: Character vector of length 2 with country names or codes (country1, country2).
- `wave`: Optional wave identifier passed to `wvs_data()`.
- `dimensions`: A named list of dimension definitions (default `dims_all`).
- `select`: Optional variables to select before scoring.
- `strict`: Logical; if TRUE, use strict scoring rules.
- `ci_level`: Confidence level for comparison intervals in (0, 1). Defaults to `0.95`.
- `max_points`: Optional maximum number of jitter points per country-dimension. Set to `NULL` to plot all finite scores.
- `seed`: Optional integer seed used when downsampling points via `max_points`.
- `path`: Optional path to local data; passed to `wvs_data()`.

### Value

An object of class `wvs_compare` (and `wvsR`) containing `title`, `countries`, `wave`, `means1`, `means2`, `points1`, and `points2`.

The returned `points1` and `points2` tables contain respondent-level scores that are displayed as jittered points by `plot.wvs_compare()`.

### Examples

```r
# wvs_compare(c("Norway", "Sweden"))
```
