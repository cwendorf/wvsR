# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Map countries into two-dimensional cultural space

### Description

Produce a two-dimensional embedding of countries using PCA, MDS, or by selecting two raw dimensions. Returns a `wvs_space` object containing the computed coordinates and plotting metadata.

### Usage

```r
wvs_space(
  method = c("pca", "mds", "dimensions"),
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL
)
```

### Arguments

- `method`: One of "pca", "mds", or "dimensions".
- `wave`: Optional wave number to restrict the data.
- `dimensions`: Named list of dimensions (default `dims_all`).
- `select`: Optional vector of dimension names to select.
- `strict`: Logical; if TRUE, use strict scoring rules.
- `path`: Optional path to the joint data file.

### Value

An object of class `wvs_space` (and `wvsR`) containing `title`, `wave`, `method`, `axis_labels`, and `coordinates`.

### Examples

```r
# Example usage
# sp <- wvs_space(method = "pca")
# plot(sp)
```
