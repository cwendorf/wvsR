# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Find nearest cultural neighbors for a country

### Description

Return the nearest `n` countries in cultural distance to the supplied country, based on country mean profiles.

### Usage

```r
wvs_neighbors(
  country,
  n = 10,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL,
  scale = TRUE
)
```

### Arguments

- `country`: Country name or ISO code.
- `n`: Number of neighbors to return (default 10).
- `wave`: Optional wave number to restrict the data.
- `dimensions`: Named list of dimensions (default `dims_all`).
- `select`: Optional vector of dimension names to select.
- `strict`: Logical; if TRUE, use strict scoring rules.
- `path`: Optional path to the joint data file.
- `scale`: Logical; if TRUE, scale dimensions prior to distance calculation.

### Value

A `wvs_neighbors` object (class inherits from `wvsR`) with `title`, `country`, `country_name`, `wave`, and `neighbors` (a data.frame with `iso`, `country`, and `distance`).

### Examples

```r
# wvs_neighbors("Sweden", n = 5)
```
