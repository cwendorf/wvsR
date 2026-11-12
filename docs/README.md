# [`wvsR`](https://github.com/cwendorf/wvsR/)

## Introduction

Cross-cultural comparisons require consistent survey measures and methods that account for uncertainty. `wvsR` uses the joint European Values Study and World Values Survey dataset to build cultural scores and compare countries.

- [Overview](#overview)
- [Resources](#resources)
- [References](#references)

---

### Overview

`wvsR` combines survey metadata with estimation-focused tools for country profiles, comparisons, and cultural distances. Its functions build cultural scores directly from survey items and support uncertainty-aware inference:

- Country profiles with confidence intervals
- Between-country comparisons with mean differences and Cohen's d
- Cultural-neighbor search and clustering
- Two-dimensional cultural maps (original dimensions, PCA, or MDS)

### Resources

- [Reference](./man/README.md): Documentation for all exported functions, including usage, arguments, return values, and examples.
- [Articles](./vignettes/README.md): Examples demonstrating how to use the functions to explore the data.

### References

EVS/WVS (2022). _European Values Study and World Values Survey: Joint EVS/WVS 2017-2022 Dataset (Joint EVS/WVS)._ JD Systems Institute & WVSA. Dataset Version 5.0.0, doi:10.14281/18241.26. https://www.worldvaluessurvey.org/WVSEVSjoint2017.jsp
