## Estimation Functions

wvs_profile <- function(
  country,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL
) {
  data <- wvs_data(country = country, wave = wave, path = path)
  scores <- wvs_score_dimensions(data, dimensions, select, strict)

  rows <- lapply(names(scores), function(dimension_name) {
    stats <- wvs_country_stats(scores[[dimension_name]])
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

  out <- list(
    title = "CULTURAL PROFILE",
    country = wvs_resolve_country(country, data),
    wave = wave,
    # dimensions = dimensions[names(scores)],
    means = do.call(rbind, rows)
  )
  class(out) <- c("wvs_profile", "wvsR")
  out
}


#' @export
plot.wvs_profile <- function(x, ...) {

  tbl <- x$means
  labels <- tbl$label
  estimate <- tbl$mean
  lower <- tbl$lower
  upper <- tbl$upper

  # DO NOT reorder — preserve input order
  n <- length(estimate)
  y <- rev(seq_len(n))

  xlim <- range(c(lower, upper, 2.5, 7.5), na.rm = TRUE)

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mar = c(4, 10, 3, 2))

  plot(
    NA,
    xlim = xlim,
    ylim = c(0.5, n + 0.5),
    yaxt = "n",
    ylab = "",
    xlab = "Score (0–10)",
    main = sprintf("Cultural Profile: %s", x$country),
    bty = "n"
  )

  axis(
    side = 2,
    at = y,
    labels = labels,
    las = 1,
    tick = FALSE
  )

  # reference line (neutral midpoint of scale)
  abline(v = 5, lty = 2, col = "grey70")

  # CI (forest plot style)
  segments(
    x0 = lower,
    y0 = y,
    x1 = upper,
    y1 = y,
    lwd = 2,
    col = "black"
  )

  # point estimate
  points(
    estimate,
    y,
    pch = 19,
    cex = 1.2
  )

  invisible(x)
}



wvs_difference <- function(
  countries,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL
) {
  if (length(countries) != 2) {
    stop("countries must be a character vector of length 2.", call. = FALSE)
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
      critical <- stats::qt(0.975, df = df)
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
      wvs_resolve_country(country1, data1),
      wvs_resolve_country(country2, data2)
    ),
    wave = wave,
    # dimensions = dimensions[names(scores1)],
    difference = do.call(rbind, rows)
  )
  class(out) <- c("wvs_difference", "wvsR")
  out
}


#' @export
plot.wvs_difference <- function(x, ...) {

  tbl <- x$difference

  labels   <- tbl$label
  estimate <- tbl$diff
  lower    <- tbl$lower
  upper    <- tbl$upper

  n <- length(estimate)
  y <- rev(seq_len(n))

  xlim <- range(c(lower, upper, 0), na.rm = TRUE)

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mar = c(4, 10, 3, 2))

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


wvs_compare <- function(
  countries,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL
) {

  if (length(countries) != 2) {
    stop("countries must be a character vector of length 2.", call. = FALSE)
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

    stats1 <- wvs_country_stats(s1)
    stats2 <- wvs_country_stats(s2)

    data.frame(
      dimension = dim_name,
      label = dimensions[[dim_name]]$label,

      mean1  = unname(stats1[["mean"]]),
      lower1 = unname(stats1[["lower"]]),
      upper1 = unname(stats1[["upper"]]),
      n1     = unname(stats1[["n"]]),

      mean2  = unname(stats2[["mean"]]),
      lower2 = unname(stats2[["lower"]]),
      upper2 = unname(stats2[["upper"]]),
      n2     = unname(stats2[["n"]]),

      stringsAsFactors = FALSE
    )
  })

  means <- do.call(rbind, rows)

means1 <- data.frame(
  dimension = means$dimension,
  label     = means$label,
  mean      = means$mean1,
  lower     = means$lower1,
  upper     = means$upper1,
  n         = means$n1,
  stringsAsFactors = FALSE
)

means2 <- data.frame(
  dimension = means$dimension,
  label     = means$label,
  mean      = means$mean2,
  lower     = means$lower2,
  upper     = means$upper2,
  n         = means$n2,
  stringsAsFactors = FALSE
)

  out <- list(
    title = "CULTURAL COMPARISON",
    countries = c(
      wvs_resolve_country(country1, data1),
      wvs_resolve_country(country2, data2)
    ),
    wave = wave,
    means1 = means1,
    means2 = means2
  )

  class(out) <- c("wvs_compare", "wvsR")
  out
}

plot.wvs_compare <- function(x, ...) {

  tbl1 <- x$means1
  tbl2 <- x$means2

  labels <- tbl1$label

  mean1  <- tbl1$mean
  lower1 <- tbl1$lower
  upper1 <- tbl1$upper

  mean2  <- tbl2$mean
  lower2 <- tbl2$lower
  upper2 <- tbl2$upper

  n <- length(labels)
  y <- rev(seq_len(n))

  y1 <- y + 0.12
  y2 <- y - 0.12

  xlim <- range(
    c(lower1, upper1, lower2, upper2, 2.5, 7.5),
    na.rm = TRUE
  )

  op <- par(no.readonly = TRUE)
  on.exit(par(op))
  par(mar = c(4, 10, 3, 2))

  plot(
    NA,
    xlim = xlim,
    ylim = c(0.5, n + 0.5),
    yaxt = "n",
    ylab = "",
    xlab = "Score (0–10)",
    main = sprintf(
      "Cultural Comparison: %s vs %s",
      x$countries[1],
      x$countries[2]
    ),
    bty = "n"
  )

  axis(
    side = 2,
    at = y,
    labels = labels,
    las = 1,
    tick = FALSE
  )

  # neutral midpoint (same as profile)
  abline(v = 5, lty = 2, col = "grey70")

  # Country 1
  segments(lower1, y1, upper1, y1, col = "steelblue", lwd = 2)
  points(mean1, y1, pch = 19, col = "steelblue")

  # Country 2
  segments(lower2, y2, upper2, y2, col = "tomato", lwd = 2)
  points(mean2, y2, pch = 19, col = "tomato")

  legend(
    "topright",
    legend = x$countries,
    col = c("steelblue", "tomato"),
    pch = 19,
    bty = "n"
  )

  invisible(x)
}
