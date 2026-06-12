## Scoring and calculations

wvs_clean_numeric <- function(x) {
  x <- as.numeric(x)
  x[x < 0] <- NA_real_
  x
}

wvs_rescale_item <- function(x, original_min, original_max, direction = 1) {
  x <- wvs_clean_numeric(x)
  out <- (x - original_min) / (original_max - original_min) * 10
  out[out < 0 | out > 10] <- NA_real_

  if (direction == -1) {
    out <- 10 - out
  }

  out
}

wvs_score_dimension <- function(data, dimension, strict = FALSE) {
  if (is.character(dimension)) {
    dimension <- dims_all[[dimension]]
  }
  if (is.null(dimension)) stop("Unknown dimension.", call. = FALSE)

  missing_vars <- vapply(dimension$items, function(item) {
    !item$var %in% names(data)
  }, logical(1))

  if (any(missing_vars) && strict) {
    vars <- vapply(dimension$items[missing_vars], `[[`, character(1), "var")
    stop("Missing variable(s): ", paste(vars, collapse = ", "), call. = FALSE)
  }

  available_items <- dimension$items[!missing_vars]
  if (length(available_items) == 0) {
    return(rep(NA_real_, nrow(data)))
  }

  item_scores <- lapply(available_items, function(item) {
    wvs_rescale_item(
      data[[item$var]],
      original_min = item$original_min,
      original_max = item$original_max,
      direction = item$direction
    )
  })

  rowMeans(do.call(cbind, item_scores), na.rm = TRUE)
}

wvs_score_dimensions <- function(
  data,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE
) {
  if (!is.null(select)) {
    missing_dims <- setdiff(select, names(dimensions))
    if (length(missing_dims) > 0) {
      stop("Unknown dimension(s): ", paste(missing_dims, collapse = ", "), call. = FALSE)
    }
    dimensions <- dimensions[select]
  }

  scores <- lapply(dimensions, function(dimension) {
    wvs_score_dimension(data, dimension, strict = strict)
  })

  as.data.frame(scores, optional = TRUE)
}

wvs_country_stats <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)

  if (n < 2) {
    return(c(mean = NA_real_, lower = NA_real_, upper = NA_real_, n = n))
  }

  estimate <- mean(x)
  se <- stats::sd(x) / sqrt(n)
  critical <- stats::qt(0.975, df = n - 1)

  c(
    mean = estimate,
    lower = estimate - critical * se,
    upper = estimate + critical * se,
    n = n
  )
}

wvs_dimensions_cache_key <- function(dimensions, select = NULL) {
  if (!is.null(select)) {
    dimensions <- dimensions[select]
  }

  pieces <- unlist(
    lapply(names(dimensions), function(dimension_name) {
      dimension <- dimensions[[dimension_name]]
      item_pieces <- vapply(dimension$items, function(item) {
        paste(
          item$var,
          item$direction,
          item$original_min,
          item$original_max,
          sep = ":"
        )
      }, character(1))

      paste(dimension_name, paste(item_pieces, collapse = ","), sep = "=")
    }),
    use.names = FALSE
  )

  paste(pieces, collapse = "|")
}
