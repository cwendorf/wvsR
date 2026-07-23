# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Plot a `wvs_profile` object

### Description

Draws a forest-style plot of mean scores and confidence intervals for each cultural dimension in a `wvs_profile` object, with respondent-level jittered points overlaid.

### Usage

```r
plot(x, jitter_height = 0.14, jitter_width = 0.03, point_cex = 0.5,
     point_alpha = 0.08, point_col = "grey30", mean_cex = 1.2, ...)
# method: plot.wvs_profile(x, ...)
```

### Arguments

- `x`: A `wvs_profile` object as returned by `wvs_profile()`.
- `jitter_height`: Vertical jitter width around each dimension row.
- `jitter_width`: Horizontal jitter width applied to respondent scores.
- `point_cex`: Expansion factor for jitter point size.
- `point_alpha`: Alpha for jitter points in [0, 1].
- `point_col`: Base color used for jitter points.
- `mean_cex`: Expansion factor for mean marker size.
- `...`: Additional plotting arguments (ignored).

### Value

The input object invisibly.

### Examples

```r
# prof <- wvs_profile("Italy")
# plot(prof)
```
