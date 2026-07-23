# [`wvsR`](https://github.com/cwendorf/wvsR/)

## List available dimensions and metadata

### Description

Return a data.frame with one row per dimension, including its assigned group (Core/Main/Extended/Dev), label and type where available.

### Usage

```r
wvs_dimensions(dimensions = dims_all)
```

### Arguments

- `dimensions`: Named list of dimension definitions (default `dims_all`).

### Value

Data.frame with columns `dimension`, `group`, `label`, and `type`.

### Examples

```r
# wvs_dimensions()
```
