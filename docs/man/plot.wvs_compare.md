# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Plot a `wvs_compare` object

### Description

Draws side-by-side jittered respondent-level points, mean scores, and confidence intervals for two countries returned by `wvs_compare()`.

### Usage

```r
plot(x, jitter_height = 0.09, jitter_width = 0.03, point_cex = 0.45,
     point_alpha = 0.08, col1 = "steelblue", col2 = "tomato",
     mean_cex = 1, ...)
# method: plot.wvs_compare(x, ...)
```

### Arguments

- `x`: A `wvs_compare` object as returned by `wvs_compare()`.
- `jitter_height`: Vertical jitter width around each country row.
- `jitter_width`: Horizontal jitter width applied to respondent scores.
- `point_cex`: Expansion factor for jitter point size.
- `point_alpha`: Alpha for jitter points in [0, 1].
- `col1`: Color for country 1.
- `col2`: Color for country 2.
- `mean_cex`: Expansion factor for mean marker size.
- `...`: Additional plotting arguments (ignored).

### Value

The input object invisibly.

### Examples

```r
# cmp <- wvs_compare(c("X","Y"))
# plot(cmp)
```
