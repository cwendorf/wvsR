# wvsR
## Estimation Functions

#' Compute a cultural profile for a single country
#'
#' Compute mean scores and confidence intervals for each cultural
#' dimension for a single country and wave using the scoring helpers
#' in this package.
#'
#' @param country Character string specifying the country name or code.
#' @param wave Optional numeric or character wave identifier. If NULL,
#'   the default (most recent) wave is used where applicable.
#' @param dimensions A named list of dimension definitions (default
#'   `dims_all`).
#' @param select Optional vector of variables to select before scoring.
#' @param strict Logical; if TRUE, use strict scoring rules when
#'   computing dimension scores.
#' @param ci_level Confidence level for profile intervals in `(0, 1)`.
#'   Defaults to `0.99`.
#' @param max_points Optional maximum number of jitter points per
#'   dimension. Set to `NULL` to plot all finite scores.
#' @param seed Optional integer seed used when downsampling points via
#'   `max_points`.
#' @param path Optional path to a local data file; passed to
#'   `wvs_data()`.
#' @return An object of class `wvs_profile` (and `wvsR`) containing
#'   `title`, `country`, `wave`, `means` (a data.frame with
#'   `dimension`, `label`, `mean`, `lower`, `upper`, `n`), and
#'   `points` (respondent-level scores for plotting).
#' @export
wvs_profile <- function(
  country,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  ci_level = 0.99,
  max_points = 5000,
  seed = NULL,
  path = NULL
) {
  if (!is.numeric(ci_level) || length(ci_level) != 1 || !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("ci_level must be a single numeric value in (0, 1).", call. = FALSE)
  }
  if (!is.null(max_points) && (!is.numeric(max_points) || length(max_points) != 1 || !is.finite(max_points) || max_points <= 0)) {
    stop("max_points must be NULL or a single positive number.", call. = FALSE)
  }

  if (!is.null(seed)) {
    old_seed <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) get(".Random.seed", envir = .GlobalEnv, inherits = FALSE) else NULL
    on.exit({
      if (is.null(old_seed)) {
        if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) rm(".Random.seed", envir = .GlobalEnv)
      } else {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      }
    }, add = TRUE)
    set.seed(seed)
  }

  data <- wvs_data(country = country, wave = wave, path = path)
  scores <- wvs_score_dimensions(data, dimensions, select, strict)

  mean_rows <- lapply(names(scores), function(dimension_name) {
    s <- scores[[dimension_name]]
    s <- s[is.finite(s)]
    stats <- wvs_country_stats(s, level = ci_level)

    data.frame(
      dimension = dimension_name,
      label = dimensions[[dimension_name]]$label,
      mean = unname(stats[["mean"]]),
      lower = unname(stats[["lower"]]),
      upper = unname(stats[["upper"]]),
      n = unname(stats[["n"]]),
      stringsAsFactors = FALSE
    )
  })

  point_rows <- lapply(names(scores), function(dimension_name) {
    s <- scores[[dimension_name]]
    s <- s[is.finite(s)]
    n_total <- length(s)

    if (!is.null(max_points) && n_total > max_points) {
      s <- sample(s, size = as.integer(max_points), replace = FALSE)
    }

    data.frame(
      dimension = dimension_name,
      label = dimensions[[dimension_name]]$label,
      score = s,
      n_total = n_total,
      stringsAsFactors = FALSE
    )
  })

  out <- list(
    title = "CULTURAL PROFILE",
    country = .wvs_iso(wvs_resolve(country, data)),
    wave = wave,
    means = do.call(rbind, mean_rows),
    points = do.call(rbind, point_rows)
  )
  class(out) <- c("wvs_profile", "wvsR")
  out
}


#' Plot a `wvs_profile` object
#'
#' Draws a forest-style plot of mean scores and confidence
#' intervals for each cultural dimension in a `wvs_profile` object,
#' with respondent-level jitter points overlaid.
#'
#' @param x A `wvs_profile` object as returned by `wvs_profile()`.
#' @param jitter_height Vertical jitter width around each dimension row.
#' @param jitter_width Horizontal jitter width applied to respondent
#'   scores.
#' @param point_cex Expansion factor for jitter point size.
#' @param point_alpha Alpha for jitter points in `[0, 1]`.
#' @param point_col Base color used for jitter points.
#' @param mean_cex Expansion factor for mean marker size.
#' @param ... Additional plotting arguments (ignored).
#' @return The input object invisibly.
#' @export
plot.wvs_profile <- function(
  x,
  jitter_height = 0.14,
  jitter_width = 0.03,
  point_cex = 0.5,
  point_alpha = 0.08,
  point_col = "grey30",
  mean_cex = 1.2,
  ...
) {
  tbl <- x$means
  pts <- x$points

  labels <- tbl$label
  estimate <- tbl$mean
  lower <- tbl$lower
  upper <- tbl$upper

  n <- length(estimate)
  y <- rev(seq_len(n))
  y_lookup <- stats::setNames(y, tbl$dimension)

  xlim_raw <- range(c(lower, upper, pts$score, 2.5, 7.5), na.rm = TRUE)
  x_span <- diff(xlim_raw)
  x_pad <- if (is.finite(x_span) && x_span > 0) 0.05 * x_span else 0.5
  xlim <- xlim_raw + c(-x_pad, x_pad)

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mar = c(5, 12, 4, 6))

  plot(
    NA,
    xlim = xlim,
    ylim = c(0.5, n + 0.5),
    yaxt = "n",
    ylab = "",
    xlab = "Score (0-10)",
    main = x$title,
    bty = "n"
  )

  axis(
    side = 2,
    at = y,
    labels = labels,
    las = 1,
    tick = FALSE
  )

  subtitle_parts <- c(
    sprintf("Country: %s", x$country),
    if (!is.null(x$wave)) sprintf("Wave: %s", x$wave)
  )
  if (length(subtitle_parts) > 0) {
    graphics::mtext(paste(subtitle_parts, collapse = "  |  "), side = 3, line = 0.7, cex = 0.95)
  }

  abline(v = 5, lty = 2, col = "grey70")

  ok_points <- is.finite(pts$score) & !is.na(pts$dimension)
  if (any(ok_points)) {
    x_jitter <- jitter(pts$score[ok_points], amount = jitter_width)
    y_base <- unname(y_lookup[pts$dimension[ok_points]])
    y_jitter <- y_base + stats::runif(sum(ok_points), min = -jitter_height, max = jitter_height)
    points(
      x = x_jitter,
      y = y_jitter,
      pch = 16,
      cex = point_cex,
      col = grDevices::adjustcolor(point_col, alpha.f = point_alpha)
    )
  }

  ok_ci <- is.finite(lower) & is.finite(upper)
  if (any(ok_ci)) {
    segments(
      x0 = lower[ok_ci],
      y0 = y[ok_ci],
      x1 = upper[ok_ci],
      y1 = y[ok_ci],
      lwd = 2,
      col = "black"
    )
  }

  points(
    estimate,
    y,
    pch = 19,
    col = "black",
    cex = mean_cex
  )

  invisible(x)
}


#' Estimate pairwise differences between two countries
#'
#' Compute mean differences (country1 − country2) and 95% confidence
#' intervals for each cultural dimension between two countries.
#'
#' @param countries Character vector of length 2 with country names or
#'   codes (country1, country2).
#' @param wave Optional wave identifier passed to `wvs_data()`.
#' @param dimensions A named list of dimension definitions (default
#'   `dims_all`).
#' @param select Optional variables to select before scoring.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param ci_level Confidence level for difference intervals in `(0, 1)`.
#'   Defaults to `0.95`.
#' @param path Optional path to local data; passed to `wvs_data()`.
#' @return An object of class `wvs_difference` (and `wvsR`) containing
#'   `title`, `countries`, `wave`, and `difference` (a
#'   data.frame with `dimension`, `label`, `diff`, `lower`, `upper`, `d`).
#' @export
wvs_difference <- function(
  countries,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  ci_level = 0.95,
  path = NULL
) {
  if (length(countries) != 2) {
    stop("countries must be a character vector of length 2.", call. = FALSE)
  }
  if (!is.numeric(ci_level) || length(ci_level) != 1 || !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("ci_level must be a single numeric value in (0, 1).", call. = FALSE)
  }

  country1 <- countries[[1]]
  country2 <- countries[[2]]

  data1 <- wvs_data(country = country1, wave = wave, path = path)
  data2 <- wvs_data(country = country2, wave = wave, path = path)
  scores1 <- wvs_score_dimensions(data1, dimensions, select, strict)
  scores2 <- wvs_score_dimensions(data2, dimensions, select, strict)

  rows <- lapply(names(scores1), function(dimension_name) {
    s1 <- scores1[[dimension_name]]
    s2 <- scores2[[dimension_name]]
    s1 <- s1[is.finite(s1)]
    s2 <- s2[is.finite(s2)]

    if (length(s1) < 2 || length(s2) < 2) {
      diff <- lower <- upper <- d <- NA_real_
    } else {
      diff <- mean(s1) - mean(s2)
      se <- sqrt(stats::var(s1) / length(s1) + stats::var(s2) / length(s2))
      df <- se^4 / (
        (stats::var(s1) / length(s1))^2 / (length(s1) - 1) +
          (stats::var(s2) / length(s2))^2 / (length(s2) - 1)
      )
      alpha <- 1 - ci_level
      critical <- stats::qt(1 - alpha / 2, df = df)
      lower <- diff - critical * se
      upper <- diff + critical * se
      pooled <- sqrt(
        ((length(s1) - 1) * stats::var(s1) + (length(s2) - 1) * stats::var(s2)) /
          (length(s1) + length(s2) - 2)
      )
      d <- if (pooled == 0) 0 else diff / pooled
    }

    data.frame(
      dimension = dimension_name,
      label = dimensions[[dimension_name]]$label,
      diff = diff,
      lower = lower,
      upper = upper,
      d = d,
      stringsAsFactors = FALSE
    )
  })

  out <- list(
    title = "CULTURAL DIFFERENCE",
    countries = c(
      .wvs_iso(wvs_resolve(country1, data1)),
      .wvs_iso(wvs_resolve(country2, data2))
    ),
    wave = wave,
    # dimensions = dimensions[names(scores1)],
    difference = do.call(rbind, rows)
  )
  class(out) <- c("wvs_difference", "wvsR")
  out
}


#' Plot a `wvs_difference` object
#'
#' Draws difference estimates and confidence intervals for each
#' dimension between two countries.
#'
#' @param x A `wvs_difference` object as returned by `wvs_difference()`.
#' @param ... Additional plotting arguments (ignored).
#' @return The input object invisibly.
#' @export
plot.wvs_difference <- function(x, ...) {

  tbl <- x$difference

  labels   <- tbl$label
  estimate <- tbl$diff
  lower    <- tbl$lower
  upper    <- tbl$upper

  n <- length(estimate)
  y <- rev(seq_len(n))

  xlim_raw <- range(c(lower, upper, 0), na.rm = TRUE)
  x_span <- diff(xlim_raw)
  x_pad <- if (is.finite(x_span) && x_span > 0) 0.05 * x_span else 0.5
  xlim <- xlim_raw + c(-x_pad, x_pad)

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mar = c(5, 12, 4, 4))

  plot(
    NA,
    xlim = xlim,
    ylim = c(0.5, n + 0.5),
    yaxt = "n",
    ylab = "",
    xlab = sprintf("Difference (%s − %s)", x$countries[1], x$countries[2]),
    main = x$title,
    bty = "n"
  )

  axis(
    side = 2,
    at = y,
    labels = labels,
    las = 1,
    tick = FALSE
  )

  # Add subtitle with countries and wave
  subtitle_parts <- c(
    sprintf("Countries: %s vs. %s", x$countries[1], x$countries[2]),
    if (!is.null(x$wave)) sprintf("Wave: %s", x$wave)
  )
  if (length(subtitle_parts) > 0) {
    graphics::mtext(paste(subtitle_parts, collapse = "  |  "), side = 3, line = 0.7, cex = 0.95)
  }

  # zero reference line (critical difference baseline)
  abline(v = 0, lty = 2, col = "grey70")

  # CI intervals
  segments(
    x0 = lower,
    y0 = y,
    x1 = upper,
    y1 = y,
    lwd = 2,
    col = "black"
  )

  # point estimates
  points(
    estimate,
    y,
    pch = 19,
    cex = 1.2
  )

  invisible(x)
}


#' Compare means for two countries side-by-side
#'
#' Compute mean scores and confidence intervals for each dimension
#' separately for two countries, returning results suitable for
#' side-by-side plotting.
#'
#' @param countries Character vector of length 2 with country names or
#'   codes (country1, country2).
#' @param wave Optional wave identifier passed to `wvs_data()`.
#' @param dimensions A named list of dimension definitions (default
#'   `dims_all`).
#' @param select Optional variables to select before scoring.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param ci_level Confidence level for comparison intervals in `(0, 1)`.
#'   Defaults to `0.95`.
#' @param max_points Optional maximum number of jitter points per
#'   country-dimension. Set to `NULL` to plot all finite scores.
#' @param seed Optional integer seed used when downsampling points via
#'   `max_points`.
#' @param path Optional path to local data; passed to `wvs_data()`.
#' @return An object of class `wvs_compare` (and `wvsR`) containing
#'   `title`, `countries`, `wave`, `means1`, `means2`, `points1`, and
#'   `points2`. `means1`/`means2` are data.frames with `dimension`,
#'   `label`, `mean`, `lower`, `upper`, `n`. `points1` and `points2`
#'   contain respondent-level scores used for plotting.
#' @export
wvs_compare <- function(
  countries,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  ci_level = 0.95,
  max_points = 1500,
  seed = NULL,
  path = NULL
) {
  if (length(countries) != 2) {
    stop("countries must be a character vector of length 2.", call. = FALSE)
  }
  if (!is.numeric(ci_level) || length(ci_level) != 1 || !is.finite(ci_level) || ci_level <= 0 || ci_level >= 1) {
    stop("ci_level must be a single numeric value in (0, 1).", call. = FALSE)
  }
  if (!is.null(max_points) && (!is.numeric(max_points) || length(max_points) != 1 || !is.finite(max_points) || max_points <= 0)) {
    stop("max_points must be NULL or a single positive number.", call. = FALSE)
  }

  if (!is.null(seed)) {
    old_seed <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) get(".Random.seed", envir = .GlobalEnv, inherits = FALSE) else NULL
    on.exit({
      if (is.null(old_seed)) {
        if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) rm(".Random.seed", envir = .GlobalEnv)
      } else {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      }
    }, add = TRUE)
    set.seed(seed)
  }

  country1 <- countries[[1]]
  country2 <- countries[[2]]

  data1 <- wvs_data(country = country1, wave = wave, path = path)
  data2 <- wvs_data(country = country2, wave = wave, path = path)

  scores1 <- wvs_score_dimensions(data1, dimensions, select, strict)
  scores2 <- wvs_score_dimensions(data2, dimensions, select, strict)

  rows <- lapply(names(scores1), function(dim_name) {
    s1 <- scores1[[dim_name]]
    s2 <- scores2[[dim_name]]

    s1 <- s1[is.finite(s1)]
    s2 <- s2[is.finite(s2)]

    stats1 <- wvs_country_stats(s1, level = ci_level)
    stats2 <- wvs_country_stats(s2, level = ci_level)

    data.frame(
      dimension = dim_name,
      label = dimensions[[dim_name]]$label,
      mean1 = unname(stats1[["mean"]]),
      lower1 = unname(stats1[["lower"]]),
      upper1 = unname(stats1[["upper"]]),
      n1 = unname(stats1[["n"]]),
      mean2 = unname(stats2[["mean"]]),
      lower2 = unname(stats2[["lower"]]),
      upper2 = unname(stats2[["upper"]]),
      n2 = unname(stats2[["n"]]),
      stringsAsFactors = FALSE
    )
  })

  means <- do.call(rbind, rows)

  point_rows1 <- lapply(names(scores1), function(dimension_name) {
    s <- scores1[[dimension_name]]
    s <- s[is.finite(s)]
    n_total <- length(s)

    if (!is.null(max_points) && n_total > max_points) {
      s <- sample(s, size = as.integer(max_points), replace = FALSE)
    }

    data.frame(
      dimension = dimension_name,
      label = dimensions[[dimension_name]]$label,
      score = s,
      n_total = n_total,
      stringsAsFactors = FALSE
    )
  })

  point_rows2 <- lapply(names(scores2), function(dimension_name) {
    s <- scores2[[dimension_name]]
    s <- s[is.finite(s)]
    n_total <- length(s)

    if (!is.null(max_points) && n_total > max_points) {
      s <- sample(s, size = as.integer(max_points), replace = FALSE)
    }

    data.frame(
      dimension = dimension_name,
      label = dimensions[[dimension_name]]$label,
      score = s,
      n_total = n_total,
      stringsAsFactors = FALSE
    )
  })

  out <- list(
    title = "CULTURAL COMPARISON",
    countries = c(
      .wvs_iso(wvs_resolve(country1, data1)),
      .wvs_iso(wvs_resolve(country2, data2))
    ),
    wave = wave,
    means1 = data.frame(
      dimension = means$dimension,
      label = means$label,
      mean = means$mean1,
      lower = means$lower1,
      upper = means$upper1,
      n = means$n1,
      stringsAsFactors = FALSE
    ),
    means2 = data.frame(
      dimension = means$dimension,
      label = means$label,
      mean = means$mean2,
      lower = means$lower2,
      upper = means$upper2,
      n = means$n2,
      stringsAsFactors = FALSE
    ),
    points1 = do.call(rbind, point_rows1),
    points2 = do.call(rbind, point_rows2)
  )
  class(out) <- c("wvs_compare", "wvsR")
  out
}

#' Plot a `wvs_compare` object
#'
#' Draws side-by-side jittered respondent-level points, mean scores,
#' and confidence intervals for two countries.
#'
#' @param x A `wvs_compare` object as returned by `wvs_compare()`.
#' @param jitter_height Vertical jitter width around each country row.
#' @param jitter_width Horizontal jitter width applied to respondent
#'   scores.
#' @param point_cex Expansion factor for jitter point size.
#' @param point_alpha Alpha for jitter points in `[0, 1]`.
#' @param col1 Color for country 1.
#' @param col2 Color for country 2.
#' @param mean_cex Expansion factor for mean marker size.
#' @param ... Additional plotting arguments (ignored).
#' @return The input object invisibly.
#' @export
plot.wvs_compare <- function(
  x,
  jitter_height = 0.09,
  jitter_width = 0.03,
  point_cex = 0.45,
  point_alpha = 0.08,
  col1 = "steelblue",
  col2 = "tomato",
  mean_cex = 1,
  ...
) {
  tbl1 <- x$means1
  tbl2 <- x$means2
  pts1 <- x$points1
  pts2 <- x$points2

  labels <- tbl1$label
  mean1 <- tbl1$mean
  lower1 <- tbl1$lower
  upper1 <- tbl1$upper
  mean2 <- tbl2$mean
  lower2 <- tbl2$lower
  upper2 <- tbl2$upper

  n <- length(labels)
  y <- rev(seq_len(n))
  y1 <- y + 0.16
  y2 <- y - 0.16
  y_lookup1 <- stats::setNames(y1, tbl1$dimension)
  y_lookup2 <- stats::setNames(y2, tbl2$dimension)

  xlim_raw <- range(
    c(lower1, upper1, lower2, upper2, pts1$score, pts2$score, 2.5, 7.5),
    na.rm = TRUE
  )
  x_span <- diff(xlim_raw)
  x_pad <- if (is.finite(x_span) && x_span > 0) 0.05 * x_span else 0.5
  xlim <- xlim_raw + c(-x_pad, x_pad)

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mar = c(5, 12, 4, 4))

  plot(
    NA,
    xlim = xlim,
    ylim = c(0.5, n + 0.5),
    yaxt = "n",
    ylab = "",
    xlab = "Score (0-10)",
    main = x$title,
    bty = "n"
  )

  axis(
    side = 2,
    at = y,
    labels = labels,
    las = 1,
    tick = FALSE
  )

  subtitle_parts <- c(
    sprintf("Countries: %s vs. %s", x$countries[1], x$countries[2]),
    if (!is.null(x$wave)) sprintf("Wave: %s", x$wave)
  )
  if (length(subtitle_parts) > 0) {
    graphics::mtext(paste(subtitle_parts, collapse = "  |  "), side = 3, line = 0.7, cex = 0.95)
  }

  abline(v = 5, lty = 2, col = "grey70")

  ok1 <- is.finite(pts1$score) & !is.na(pts1$dimension)
  if (any(ok1)) {
    x_jitter1 <- jitter(pts1$score[ok1], amount = jitter_width)
    y_base1 <- unname(y_lookup1[pts1$dimension[ok1]])
    y_jitter1 <- y_base1 + stats::runif(sum(ok1), min = -jitter_height, max = jitter_height)
    points(
      x = x_jitter1,
      y = y_jitter1,
      pch = 16,
      cex = point_cex,
      col = grDevices::adjustcolor(col1, alpha.f = point_alpha)
    )
  }

  ok2 <- is.finite(pts2$score) & !is.na(pts2$dimension)
  if (any(ok2)) {
    x_jitter2 <- jitter(pts2$score[ok2], amount = jitter_width)
    y_base2 <- unname(y_lookup2[pts2$dimension[ok2]])
    y_jitter2 <- y_base2 + stats::runif(sum(ok2), min = -jitter_height, max = jitter_height)
    points(
      x = x_jitter2,
      y = y_jitter2,
      pch = 16,
      cex = point_cex,
      col = grDevices::adjustcolor(col2, alpha.f = point_alpha)
    )
  }

  segments(lower1, y1, upper1, y1, col = col1, lwd = 2)
  segments(lower2, y2, upper2, y2, col = col2, lwd = 2)

  points(mean1, y1, pch = 19, col = col1, cex = mean_cex)
  points(mean2, y2, pch = 19, col = col2, cex = mean_cex)

  legend(
    "topright",
    legend = x$countries,
    col = c(col1, col2),
    pch = 16,
    bty = "n"
  )

  invisible(x)
}
