# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Custom Dimensions

This page shows how to define custom dimensions and use them with the same profile and comparison functions as the default EVS/WVS set.

### Define a Dimension Set

A dimension set is a named list. Each dimension has a label and a type. The items are specified as a character vector of variable names - the codebook automatically fills in the response ranges and directions for you.

```r
dims_custom <- list(
  SocialProgressivism = list(
    label = "Social Progressivism",
    type = "mean",
    items = c("F118", "F119", "F120", "F121", "F122", "D059", "G052")
  ),

  MarketSkepticism = list(
    label = "Market Skepticism",
    type = "mean",
    items = c("E035", "E036", "E037", "E039", "E033")
  )
)
```

### Validate the Variables

List the items used in each custom dimension so you can verify labels and ranges before computing scores.

```r
wvs_items(
  vars = c("F118", "F119", "F120", "F121", "F122", "D059", "G052")
)
wvs_items(
  vars = c("E035", "E036", "E037", "E039", "E033")
)
```

### Use the Custom Set

Profile a single country using the custom dimensions and plot the result:

```r
wvs_profile("JP", dimensions = dims_custom) |> plot()
```

Compare two countries on the custom dimensions and plot their differences:

```r
wvs_difference(countries = c("JP", "US"), dimensions = dims_custom) |> plot()
```

Project countries into the two-dimensional space defined by the selected custom dimensions and highlight the US and JP:

```r
wvs_space(
  method = "dimensions",
  dimensions = dims_custom,
  select = c("SocialProgressivism", "MarketSkepticism"),
  highlight = c("US", "JP")
) |> plot()
```
