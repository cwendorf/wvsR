# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Reference

This section is the reference for `wsvR`. Each page documents one exported function, including usage, arguments, return values, and examples.

### Data Definitions

- [wvs_items](./wvs_items.md): Retrieve hlabels, groups, directions, ranges for survey variables from the EVS/WVS codebook.
- [wvs_dimensions](./wvs_dimensions.md): List available cultural dimensions and metadata.
- [wvs_countries](./wvs_countries.md): List available countries in the joint dataset and return info for specified countries.

### Cultural Estimates

- [wvs_profile](./wvs_profile.md): Compute mean scores and confidence intervals for every cultural dimension for a single country and wave. Also has an associated plot method.
- [wvs_difference](./wvs_difference.md): Estimate pairwise mean differences (with confidence intervals) between two countries across dimensions. Also has an associated plot method.
- [wvs_compare](./wvs_compare.md): Compute side-by-side means and intervals for two countries, returning structures suitable for paired plotting and comparison. Also has an associated plot method.

### Cultural Distances

- [wvs_space](./wvs_space.md): Map countries into a two-dimensional cultural space using PCA, MDS, or two selected dimensions. By default, returns a plot.
- [wvs_neighbors](./wvs_neighbors.md): Find the nearest cultural neighbors (by distance) for a given country.
- [wvs_clusters](./wvs_clusters.md): Cluster countries into cultural groups using k-means on country mean profiles.
