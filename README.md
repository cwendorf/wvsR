# wvsR

## Cross-Cultural Comparisons Using WVS Data

[![minimal R version](https://img.shields.io/badge/R%3E%3D-3.6.2-6666ff.svg)](https://cran.r-project.org/)
[![License: GPL-3](https://img.shields.io/badge/License-GPL--3-blue.svg)](https://opensource.org/licenses/GPL-3.0)

### Overview

`wvsR` is an estimation-focused toolkit for cross-cultural comparison
using the EVS/WVS Joint Dataset. In addition to building cultural scores directly
from survey items, the package prioritizes uncertainty-aware inference:

- Country profiles with confidence intervals
- Between-country comparisons with mean differences and Cohen's d
- Cultural-neighbor search and clustering
- Two-dimensional cultural maps (original dimensions, PCA, or MDS)

### Installation

This package is not currently on CRAN. Install from GitHub:

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("cwendorf/wvsR")
library(wvsR)
```

If you do not want a full install, source the latest function bundle directly:

```r
source("https://raw.githubusercontent.com/cwendorf/cultureCompareR/main/source-wvsR.R")
```

### Usage

This package includes the following documentation:

- [Introduction](./docs/README.md): A quick overview and summary of the package.
- [Data Basics](./docs/basics.md): Functions for country coverage, the survey items, and the available dimensions.
- [Estimation Approach](./docs/estimation.md): Functions for getting country profiles, comparisons of countries, and country differences.
- [Cultural Distances](./docs/distances.md): Functions for dimension mapping, identification of most similar countries, and clustering.
- [Custom Dimensions](./docs/custom.md): Functions for building and using custom dimensions.

### Contact

- GitHub Issues: [https://github.com/cwendorf/wvsR/issues](https://github.com/cwendorf/wvsR/issues)
- Author Email: [cwendorf@uwsp.edu](mailto:cwendorf@uwsp.edu)
- Author Homepage: [https://github.com/cwendorf](https://github.com/cwendorf)

### Citation

Wendorf, C.A. (2026). *wvsR: Cross-cultural comparisons using WVS data* [R Package]. [https://github.com/cwendorf/wvsR](https://github.com/cwendorf/wvsR)
