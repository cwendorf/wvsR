# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Cluster countries into cultural groups

### Description

Perform k-means clustering on country mean profiles to assign countries to `k` clusters and compute cluster centroids.

### Usage

```r
wvs_clusters(
  k = 5,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL,
  seed = 42
)
```

### Arguments

- `k`: Number of clusters (default 5).
- `wave`: Optional wave number to restrict the data.
- `dimensions`: Named list of dimensions (default `dims_all`).
- `select`: Optional vector of dimension names to select.
- `strict`: Logical; if TRUE, use strict scoring rules.
- `path`: Optional path to the joint data file.
- `seed`: Integer seed for reproducible clustering.

### Value

A `wvs_clusters` object (class inherits from `wvsR`) with `title`, `wave`, `k`, `assignments` (data.frame), and `cluster_means` (list of numeric vectors).

### Examples

```r
# wvs_clusters(k = 4)
```
