# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Cultural Distances

`wvsR` includes tools for visualising cultural differences across countries. These can be used to explore the relationships between dimensions, identify clusters of similar cultures, and highlight specific countries of interest.

### Mapping Countries

`wvs_space()` can map countries directly on two named dimensions.

```r
wvs_space(
  method = "dimensions",
  select = c("Tradition", "Survival"),
  highlight = c("US", "CA")
)
```

```r
wvs_space(
  method = "dimensions",
  select = c("Survival", "Tradition"),
  highlight = c("US", "CA")
) |> plot()
```

```r
wvs_space(
  method = "dimensions",
  select = c("SurvivalSelfExpression", "TraditionalSecular"),
  highlight = c("US", "CA")
) |> plot()
```

```r
wvs_space(
  method = "dimensions",
  select = c("Religiosity", "Economic"),
  highlight = c("US")
) |> plot()
```

```r
wvs_space(
  method = "dimensions",
  select = c("Democracy", "DemocraticValues"),
  highlight = c("US")
) |> plot()
```

It can also reduce a larger selected dimension space with PCA or MDS.

```r
wvs_space(
  method = "pca",
  dimensions = dims_main,
  highlight = c("US", "CA")
)
```

```r
wvs_space(
  method = "pca",
  dimensions = dims_main,
  highlight = c("US", "CA")
) |> plot()
```

```r
wvs_space(
  method = "mds",
  dimensions = dims_all,
  highlight = c("US", "CA")
)
```

```r
wvs_space(
  method = "mds",
  dimensions = dims_all,
  highlight = c("US", "CA")
) |> plot()
```

### Similar Countries

`wvs_neighbors()` ranks countries by Euclidean distance across the selected dimension means.

```r
wvs_neighbors(
  "US",
  n = 5,
  dimensions = dims_main
)
```

```r
wvs_neighbors(
  "US",
  n = 5,
  select = c("Economic")
)
```

### Clustering Countries

`wvs_clusters()` applies k-means clustering to the selected country mean profiles.

```r
wvs_clusters(
  k = 4,
  dimensions = dims_main
)
```
