# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Plot a `wvs_space` object

### Description

Draws a two-dimensional cultural map using coordinates returned by `wvs_space()`.

### Usage

```r
plot(x, ...)
# method: plot.wvs_space(x, ...)
```

### Arguments

- `x`: A `wvs_space` object as returned by `wvs_space()`.
- `highlight`: Optional character vector of countries to highlight on the plot (names or ISO codes).
- `...`: Additional plotting arguments (ignored).

### Value

The input object invisibly.

### Examples

```r
# sp <- wvs_space()
# plot(sp)
```
