# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Retrieve variable label

### Description

Retrieve variable label(s).

### Usage

```r
wvs_items(
  vars = NULL,
  group = NULL,
  columns = c("label", "group", "direction", "min", "max")
)
```

### Arguments

- `vars`: Optional character vector of variable names to include.
- `group`: Optional character vector of groups to include.
- `columns`: Optional character vector of columns to return. Valid values are `"label"`, `"group"`, `"direction"`, `"min"`, and `"max"`.

### Value

Data.frame describing item metadata. Row names are variable names.

### Examples

```r
# wvs_items(vars = c("v1", "v2"))
```
