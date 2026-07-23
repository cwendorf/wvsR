# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Plot a `wvs_difference` object

### Description

Draws difference estimates and confidence intervals for each dimension between two countries.

### Usage

```r
plot(x, ...)
# method: plot.wvs_difference(x, ...)
```

### Arguments

- `x`: A `wvs_difference` object as returned by `wvs_difference()`.
- `...`: Additional plotting arguments (ignored).

### Value

The input object invisibly.

### Examples

```r
# diff <- wvs_difference(c("A", "B"))
# plot(diff)
```
