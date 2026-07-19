# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Estimation Approach

Most cross-cultural tools report just country scores and leave the user to judge whether the scores differ meaningfully. `wvsR` takes a different approach - every quantity is reported as an estimate with uncertainty.

This means:

- Point estimates (means) are accompanied by confidence intervals.
- Comparisons report the mean difference in the original metric along with the CI, not just a significance test.
- Effect sizes (Cohen's d) contextualise how large a difference is relative to within-country variability.

### Country Profiles

`wvs_profile()` estimates each selected dimension for one country and returns the mean, confidence interval, and valid respondent count. Its default plot overlays respondent-level jittered scores.

```r
wvs_profile(
  "US",
  dimensions = dims_extended
)
```

```r
wvs_profile(
  "US",
  dimensions = dims_extended
) |> plot()
```

The same function can use specified dimensions instead.

```r
wvs_profile(
  "US",
  select = c("Tradition", "Survival")
) |> plot()
```

### Country Comparisons

Use `wvs_compare()` to prepare mean tables separately for the two countries. It is also useful for comparison plotting and includes respondent-level jitter points.

```r
wvs_compare(
  countries = c("US", "CA"),
  dimensions = dims_extended
)
```

```r
wvs_compare(
  countries = c("US", "CA"),
  dimensions = dims_extended
) |> plot()
```

```r
wvs_compare(
  countries = c("US", "CA"),
  select = c("Tradition", "Survival")
) |> plot()
```

### Country Differences

`wvs_difference()` estimates the difference between countries on each selected dimension. Positive values mean the first country scored higher.

```r
wvs_difference(
  countries = c("US", "CA"),
  dimensions = dims_core
)
```

```r
wvs_difference(
  countries = c("US", "CA"),
  dimensions = dims_extended
) |> plot()
```

```r
wvs_difference(
  countries = c("US", "CA"),
  select = c("Tradition", "Survival")
) |> plot()
```

```r
wvs_difference(
  countries = c("US", "CA"),
  dimensions = c(dims_core, dims_main)
)
```
