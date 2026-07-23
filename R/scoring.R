# wvsR
## Scoring and Calculation Functions

#' Clean numeric responses
#'
#' Convert values to numeric, suppressing warnings, and treat any
#' negative values as missing (`NA`). This helper is used throughout
#' scoring routines to normalise input vectors.
#'
#' @param x Vector to coerce to numeric.
#' @return Numeric vector with negative values set to `NA`.
#' @keywords internal
wvs_clean_numeric <- function(x) {
  if (inherits(x, c("haven_labelled", "labelled", "labelled_spss"))) {
    x <- unclass(x)
  }
  if (is.factor(x)) {
    x <- as.character(x)
  }
  x <- suppressWarnings(as.numeric(x))
  x[x < 0] <- NA_real_
  x
}

#' Orient item responses to a common direction
#'
#' Optionally flip item responses so that higher values indicate more
#' of the focal construct. Accepts alternate attribute-based min
#' metadata for compatibility with developer dictionaries.
#'
#' @param x Numeric vector of responses.
#' @param original_min Optional numeric minimum of the original scale.
#' @param original_max Optional numeric maximum of the original scale.
#' @param direction Direction multiplier (1 or -1).
#' @return Numeric vector with values flipped when `direction == -1`.
#' @keywords internal
orient_item <- function(x, original_min = NULL, original_max = NULL, direction = 1) {
  x <- wvs_clean_numeric(x)

  # Accept alternate field names for compatibility with dev dictionaries
  if (is.null(original_min) && !is.null(attr(x, "min"))) {
    original_min <- attr(x, "min")
  }

  if (!is.null(original_min) && !is.null(original_max) && direction < 0) {
    # flip relative to min/max
    x <- original_max + original_min - x
  }

  x
}

#' Rescale an item to a 0–10 scale
#'
#' Linearly rescales item responses from their original scale to a
#' 0–10 range and applies directional flipping when requested.
#'
#' @param x Numeric vector of responses.
#' @param original_min Numeric minimum of the original scale.
#' @param original_max Numeric maximum of the original scale.
#' @param direction Direction multiplier (1 or -1).
#' @return Numeric vector on a 0–10 scale with out-of-range values
#'   set to `NA`.
#' @keywords internal
wvs_rescale_item <- function(x, original_min, original_max, direction = 1) {
  x <- wvs_clean_numeric(x)
  out <- (x - original_min) / (original_max - original_min) * 10
  out[out < 0 | out > 10] <- NA_real_

  if (direction == -1) out <- 10 - out

  out
}

#' Compute mean-based dimension scores
#'
#' Aggregate item responses for a dimension using the row-wise mean.
#' Supports raw, rescaled (0–10), and z-score aggregation modes.
#'
#' @param data Data.frame with item variables.
#' @param dim A dimension list containing an `items` element.
#' @param method One of `"raw"`, `"rescaled"`, or `"z"`.
#' @return Numeric vector of dimension scores (one per row of `data`).
#' @keywords internal
score_mean <- function(data, dim, method = "rescaled") {
  items <- dim$items
  M <- as.data.frame(lapply(items, function(i) {
    # support both schemas: i$original_min / original_max or i$min / i$max
    minv <- if (!is.null(i$original_min)) i$original_min else i$min
    maxv <- if (!is.null(i$original_max)) i$original_max else i$max
    dir <- if (!is.null(i$direction)) i$direction else 1
    v <- wvs_clean_numeric(data[[i$var]])
    if (method == "rescaled") {
      wvs_rescale_item(v, minv, maxv, dir)
    } else {
      # raw or z: optionally flip so higher = more construct
      if (!is.null(minv) && !is.null(maxv) && dir < 0) v <- maxv + minv - v
      v
    }
  }))

  if (method == "z") {
    M[] <- lapply(M, function(x) as.numeric(scale(x)))
  }

  rowMeans(M, na.rm = TRUE)
}

#' Score contrast/contrast-style dimensions (autonomy)
#'
#' Compute a contrast score as the difference between the mean of
#' `positive` items and the mean of `negative` items. Optionally
#' standardise the resulting contrast.
#'
#' @param data Data.frame with item variables.
#' @param positive Character vector of variable names for the
#'   positive items.
#' @param negative Character vector of variable names for the
#'   negative items.
#' @param method One of `"raw"` or `"z"`.
#' @return Numeric vector of contrast scores.
#' @keywords internal
score_autonomy <- function(data, positive, negative, method = "rescaled") {
  pos <- rowMeans(as.data.frame(lapply(positive, function(v) wvs_clean_numeric(data[[v]]))), na.rm = TRUE)
  neg <- rowMeans(as.data.frame(lapply(negative, function(v) wvs_clean_numeric(data[[v]]))), na.rm = TRUE)
  x <- pos - neg
  if (method == "z") x <- as.numeric(scale(x))
  x
}

#' Score postmaterialism index
#'
#' Compute a simple three-category postmaterialism index from two
#' survey items following common coding rules.
#'
#' @param data Data.frame containing the two indicator variables.
#' @param vars Character vector of length 2 with the variable names
#'   to use (expected `c("E001","E002")`).
#' @return Integer vector with values 1 (materialist), 2
#'   (mixed), or 3 (postmaterialist).
#' @keywords internal
score_postmaterialism <- function(data, vars) {
  # vars expected to be c("E001","E002")
  f <- wvs_clean_numeric(data[[vars[1]]])
  s <- wvs_clean_numeric(data[[vars[2]]])
  ifelse(f %in% c(3, 4) & s %in% c(3, 4), 3,
         ifelse(f %in% c(1, 2) & s %in% c(1, 2), 1, 2))
}

#' Score a single dimension for a dataset
#'
#' Compute scores for a single named dimension definition. Supports
#' different dimension `type`s including `mean` (item average),
#' `contrast`, and `lookup` (special coding rules).
#'
#' @param data Data.frame of survey responses.
#' @param dimension A dimension list or the name of a dimension in
#'   `dims_all`.
#' @param strict Logical; if TRUE, missing variables cause an error.
#' @param method One of `"raw"`, `"rescaled"`, or `"z"`.
#' @return Numeric vector of dimension scores (one per row of `data`).
#' @keywords internal
#' @noRd
wvs_score_dimension <- function(data, dimension, strict = FALSE, method = c("rescaled", "raw", "z")) {
  method <- match.arg(method)
  if (is.character(dimension)) {
    dimension <- dims_all[[dimension]]
  }
  if (is.null(dimension)) stop("Unknown dimension.", call. = FALSE)

  # Handle different dimension types: mean (items), contrast (positive/negative), lookup (vars)
  if (!is.null(dimension$type) && dimension$type == "contrast") {
    pos <- dimension$positive
    neg <- dimension$negative
    missing_pos <- setdiff(pos, names(data))
    missing_neg <- setdiff(neg, names(data))
    if (length(c(missing_pos, missing_neg)) && strict) stop("Missing variable(s)", call. = FALSE)
    return(score_autonomy(data, pos, neg, method = method))
  }

  if (!is.null(dimension$type) && dimension$type == "lookup") {
    vars <- dimension$vars
    if (any(!vars %in% names(data))) {
      if (strict) stop("Missing variable(s)", call. = FALSE)
      return(rep(NA_real_, nrow(data)))
    }
    return(score_postmaterialism(data, vars))
  }

  # Resolve items to ensure they're full item specs (handles character vectors and lists)
  items <- resolve_dimension_items(dimension$items)

  missing_vars <- vapply(items, function(item) {
    !item$var %in% names(data)
  }, logical(1))

  if (any(missing_vars) && strict) {
    vars <- vapply(items[missing_vars], `[[`, character(1), "var")
    stop("Missing variable(s): ", paste(vars, collapse = ", "), call. = FALSE)
  }

  available_items <- items[!missing_vars]
  if (length(available_items) == 0) {
    return(rep(NA_real_, nrow(data)))
  }

  dim_tmp <- list(items = available_items)
  score_mean(data, dim_tmp, method = method)
}

#' Score multiple dimensions for a dataset
#'
#' Apply `wvs_score_dimension()` across a named list of dimensions and
#' return a data.frame with one column per dimension.
#'
#' @param data Data.frame of survey responses.
#' @param dimensions Named list of dimensions (default `dims_all`).
#' @param select Optional character vector selecting a subset of
#'   dimensions from `dimensions`.
#' @param strict Logical; if TRUE, missing variables cause an error.
#' @param method One of `"raw"`, `"rescaled"`, or `"z"`.
#' @return Data.frame with one column per scored dimension.
#' @keywords internal
#' @noRd
wvs_score_dimensions <- function(data, dimensions = dims_all, select = NULL, strict = FALSE, method = c("rescaled", "raw", "z")) {
  method <- match.arg(method)
  if (!is.null(select)) {
    missing_dims <- setdiff(select, names(dimensions))
    if (length(missing_dims) > 0) {
      stop("Unknown dimension(s): ", paste(missing_dims, collapse = ", "), call. = FALSE)
    }
    dimensions <- dimensions[select]
  }

  scores <- lapply(dimensions, function(dimension) {
    wvs_score_dimension(data, dimension, strict = strict, method = method)
  })

  as.data.frame(scores, optional = TRUE)
}

#' Estimate factor-analytic scores for a dimension
#'
#' Fit a one-factor model using `factanal()` and return the fitted
#' object (useful when researcher prefers factor scores to simple
#' averages).
#'
#' @param data Data.frame of item responses.
#' @param dimension Dimension list containing `items`.
#' @return A `factanal` fit object with regression scores.
#' @keywords internal
#' @noRd
wvs_factor_score <- function(data, dimension) {
  items <- resolve_dimension_items(dimension$items)
  M <- as.data.frame(lapply(items, function(i) {
    minv <- if (!is.null(i$original_min)) i$original_min else i$min
    maxv <- if (!is.null(i$original_max)) i$original_max else i$max
    dir <- if (!is.null(i$direction)) i$direction else 1
    v <- wvs_clean_numeric(data[[i$var]])
    if (!is.null(minv) && !is.null(maxv) && dir < 0) v <- maxv + minv - v
    v
  }))
  M <- M[, colSums(!is.na(M)) > 0, drop = FALSE]
  fit <- factanal(na.omit(M), factors = 1, scores = "regression")
  fit
}

#' Compute PCA on dimension items
#'
#' Perform a principal components analysis of the items comprising a
#' dimension and return the `prcomp` object.
#'
#' @param data Data.frame of item responses.
#' @param dimension Dimension list containing `items`.
#' @return A `prcomp` object for the scaled item matrix.
#' @keywords internal
#' @noRd
wvs_pca_score <- function(data, dimension) {
  items <- resolve_dimension_items(dimension$items)
  M <- as.data.frame(lapply(items, function(i) {
    minv <- if (!is.null(i$original_min)) i$original_min else i$min
    maxv <- if (!is.null(i$original_max)) i$original_max else i$max
    dir <- if (!is.null(i$direction)) i$direction else 1
    v <- wvs_clean_numeric(data[[i$var]])
    if (!is.null(minv) && !is.null(maxv) && dir < 0) v <- maxv + minv - v
    v
  }))
  M <- scale(M)
  prcomp(M)
}

#' Weighted aggregate of scores by country
#'
#' Compute a weighted mean of a score vector grouped by country.
#'
#' @param data Data.frame containing `country` and `weight` variables.
#' @param score Numeric vector of scores aligned with `data` rows.
#' @param country Name of the country column in `data` (default
#'   "cntry").
#' @param weight Name of the sampling weight column (default
#'   "gwght").
#' @return Data.frame with grouped weighted means.
#' @keywords internal
#' @noRd
weighted_country_aggregate <- function(data, score, country = "cntry", weight = "gwght") {
  aggregate(score, list(country = data[[country]]), function(x) weighted.mean(x, data[[weight]][seq_along(x)], na.rm = TRUE))
}

#' Country-level summary statistics for a score vector
#'
#' Compute mean, confidence interval and sample size for a
#' numeric vector of scores, returning `NA`-filled results when fewer
#' than two observations are available.
#'
#' @param x Numeric vector of scores.
#' @param level Confidence level for interval bounds in `(0, 1)`.
#'   Defaults to `0.95`.
#' @return Named numeric vector with elements `mean`, `lower`,
#'   `upper`, and `n`.
#' @keywords internal
#' @noRd
wvs_country_stats <- function(x, level = 0.95) {
  if (!is.numeric(level) || length(level) != 1 || !is.finite(level) || level <= 0 || level >= 1) {
    stop("level must be a single numeric value in (0, 1).", call. = FALSE)
  }

  x <- x[is.finite(x)]
  n <- length(x)

  if (n < 2) {
    return(c(mean = NA_real_, lower = NA_real_, upper = NA_real_, n = n))
  }

  estimate <- mean(x)
  se <- stats::sd(x) / sqrt(n)
  alpha <- 1 - level
  critical <- stats::qt(1 - alpha / 2, df = n - 1)

  c(
    mean = estimate,
    lower = estimate - critical * se,
    upper = estimate + critical * se,
    n = n
  )
}

#' Build a cache key for a set of dimensions
#'
#' Create a deterministic string representing the composition of a
#' set of dimensions (and their items) suitable for caching purposes.
#'
#' @param dimensions Named list of dimensions.
#' @param select Optional subset of dimension names to include.
#' @return Character scalar suitable for use as a cache key.
#' @keywords internal
wvs_dimensions_cache_key <- function(dimensions, select = NULL) {
  if (!is.null(select)) dimensions <- dimensions[select]

  pieces <- unlist(lapply(names(dimensions), function(dimension_name) {
    dimension <- dimensions[[dimension_name]]
    # Resolve items to ensure they're full item specs
    items <- resolve_dimension_items(dimension$items)
    item_pieces <- vapply(items, function(item) {
      # support both field names
      minv <- if (!is.null(item$original_min)) item$original_min else item$min
      maxv <- if (!is.null(item$original_max)) item$original_max else item$max
      dir <- if (!is.null(item$direction)) item$direction else 1
      paste(item$var, dir, minv, maxv, sep = ":")
    }, character(1))
    paste(dimension_name, paste(item_pieces, collapse = ","), sep = "=")
  }), use.names = FALSE)

  paste(pieces, collapse = "|")
}
