# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Estimate pairwise differences between two countries

### Description

Compute mean differences (country1 − country2) and 95% confidence intervals for each cultural dimension between two countries.

### Usage

```r
wvs_difference(
  countries,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  ci_level = 0.95,
  path = NULL
)
```

### Arguments

- `countries`: Character vector of length 2 with country names or codes (country1, country2).
- `wave`: Optional wave identifier passed to `wvs_data()`.
- `dimensions`: A named list of dimension definitions (default `dims_all`).
- `select`: Optional variables to select before scoring.
- `strict`: Logical; if TRUE, use strict scoring rules.
- `ci_level`: Confidence level for difference intervals in (0, 1). Defaults to `0.95`.
- `path`: Optional path to local data; passed to `wvs_data()`.

### Value

An object of class `wvs_difference` (and `wvsR`) containing `title`, `countries`, `wave`, and `difference` (a data.frame with `dimension`, `label`, `diff`, `lower`, `upper`, `d`).

### Examples

```r
# wvs_difference(c("France", "Germany"))
```
