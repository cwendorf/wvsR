# [`wvsR`](https://github.com/cwendorf/wvsR/)

## List info for one or more countries

### Description

When called without `countries`, returns a data.frame listing ISO code, display name and number of respondents for each country in the joint dataset (optionally restricted to a specific `wave`). When `countries` is provided, returns a `wvs_countries` object with data for the requested country or countries.

### Usage

```r
wvs_countries(countries = NULL, wave = NULL, path = NULL)
```

### Arguments

- `countries`: Optional country name(s) or ISO code(s) to query.
- `wave`: Optional wave number to restrict the dataset.
- `path`: Optional path to data; passed to `wvs_load()`.

### Value

A `wvs_countries` object with `title`, `wave`, and `countries`.

### Examples

```r
# wvs_countries()
# wvs_countries(c("USA", "CAN"))
```
