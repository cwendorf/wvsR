# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Compute a cultural profile for a single country

### Description

Compute mean scores and confidence intervals for each cultural dimension for a single country and wave.

### Usage

```r
wvs_profile(
  country,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  ci_level = 0.99,
  max_points = 5000,
  seed = NULL,
  path = NULL
)
```

### Arguments

- `country`: Character string specifying the country name or code.
- `wave`: Optional numeric or character wave identifier. If NULL, the default (most recent) wave is used where applicable.
- `dimensions`: A named list of dimension definitions (default `dims_all`).
- `select`: Optional vector of variables to select before scoring.
- `strict`: Logical; if TRUE, use strict scoring rules when computing dimension scores.
- `ci_level`: Confidence level for profile intervals in (0, 1). Defaults to `0.99`.
- `max_points`: Optional maximum number of jitter points per dimension. Set to `NULL` to plot all finite scores.
- `seed`: Optional integer seed used when downsampling points via `max_points`.
- `path`: Optional path to a local data file; passed to `wvs_data()`.

### Value

An object of class `wvs_profile` (and `wvsR`) containing `title`, `country`, `wave`, `means` (a data.frame with `dimension`, `label`, `mean`, `lower`, `upper`, `n`), and `points` (respondent-level scores for plotting).

The returned `points` table contains the respondent-level scores that are displayed as jittered points by `plot.wvs_profile()`.

### Examples

```r
# prof <- wvs_profile("United States")
# plot(prof)
```
