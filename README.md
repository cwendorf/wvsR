# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Cross-Cultural Comparisons Using WVS Data

[![Minimal R Version](https://img.shields.io/badge/R%3E%3D-3.6.2-blue?style=for-the-badge)](https://cran.r-project.org/)
[![GitHub Release](https://img.shields.io/github/v/release/cwendorf/wvsR?style=for-the-badge)](https://github.com/cwendorf/wvsR/releases/latest)
[![Project Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)](https://www.repostatus.org/#active)

### Overview

`wvsR` is an estimation-focused R package for cross-cultural comparison using the EVS/WVS Joint Dataset. In addition to building cultural scores directly from survey items, the package prioritizes uncertainty-aware inference:

- Country profiles with confidence intervals
- Between-country comparisons with mean differences and Cohen's d
- Cultural-neighbor search and clustering
- Two-dimensional cultural maps (original dimensions, PCA, or MDS)

### Installation

This package is not currently available on CRAN. It can be installed directly from GitHub:

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("cwendorf/wvsR")
library(wvsR)
```

If you prefer not to install the package, you can load the current functions directly:

```r
source("https://raw.githubusercontent.com/cwendorf/wvsR/main/source-wvsR.R")
```

### Usage

This package includes the following documentation:

- [Introduction](./docs/README.md): A quick overview and summary of the package.
- [Reference](./docs/man/README.md): Documentation for all exported functions, including usage, arguments, return values, and examples.
- [Articles](./docs/vignettes/README.md): Examples demonstrating how to use the functions to explore the data.

### Citation

Wendorf, C.A. (2026). *wvsR: Cross-cultural comparisons using WVS data* [R Package]. [https://github.com/cwendorf/wvsR](https://github.com/cwendorf/wvsR)
