# wvsR
## Cultural Distance Functions

#' Compute country-level means for dimensions
#'
#' Compute mean scores for each country across the supplied set of
#' dimensions. Results are cached in-memory to avoid repeated
#' computation.
#'
#' @param wave Optional wave number to restrict the data.
#' @param dimensions Named list of dimensions (default `dims_all`).
#' @param select Optional vector of dimension names to select.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param path Optional path to the joint data file.
#' @return A data.frame with one row per country and one column per
#'   dimension (plus `iso`).
#' @keywords internal
wvs_means <- function(
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL
) {
  cache_key <- paste(
    "country_means",
    wvs_path(path),
    if (is.null(wave)) "all_waves" else paste0("wave_", wave),
    strict,
    wvs_dimensions_cache_key(dimensions, select),
    sep = "::"
  )

  if (exists(cache_key, envir = wvs_cache, inherits = FALSE)) {
    return(get(cache_key, envir = wvs_cache, inherits = FALSE))
  }

  data <- wvs_data(wave = wave, path = path)
  countries <- sort(unique(as.character(data$cntry_AN)))

  rows <- lapply(countries, function(iso) {
    country_data <- data[as.character(data$cntry_AN) == iso, , drop = FALSE]
    scores <- wvs_score_dimensions(country_data, dimensions, select, strict)
    means <- vapply(scores, function(x) mean(x, na.rm = TRUE), numeric(1))
    data.frame(iso = iso, as.list(means), check.names = FALSE)
  })

  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  assign(cache_key, out, envir = wvs_cache)
  out
}

#' Compute pairwise cultural distances between countries
#'
#' Compute Euclidean distances between country mean profiles across
#' the selected dimensions. Optionally scales each dimension to
#' zero-mean/unit-variance before computing distances.
#'
#' @param wave Optional wave number to restrict the data.
#' @param dimensions Named list of dimensions (default `dims_all`).
#' @param select Optional vector of dimension names to select.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param path Optional path to the joint data file.
#' @param scale Logical; if TRUE, scale dimensions prior to distance
#'   calculation.
#' @return An object of class `dist` with pairwise distances between
#'   countries.
#' @keywords internal
wvs_distances <- function(
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL,
  scale = TRUE
) {
  means <- wvs_means(
    wave = wave,
    dimensions = dimensions,
    select = select,
    strict = strict,
    path = path
  )

  mat <- as.matrix(means[, setdiff(names(means), "iso"), drop = FALSE])
  rownames(mat) <- means$iso
  mat <- mat[stats::complete.cases(mat), , drop = FALSE]

  if (nrow(mat) < 2) {
    stop("Fewer than 2 countries have complete dimension scores.", call. = FALSE)
  }

  if (isTRUE(scale)) {
    mat <- scale(mat)
  }

  stats::dist(mat)
}

#' Find nearest cultural neighbors for a country
#'
#' Return the nearest `n` countries in cultural distance to the
#' supplied country, based on country mean profiles.
#'
#' @param country Country name or ISO code.
#' @param n Number of neighbors to return (default 10).
#' @param wave Optional wave number to restrict the data.
#' @param dimensions Named list of dimensions (default `dims_all`).
#' @param select Optional vector of dimension names to select.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param path Optional path to the joint data file.
#' @param scale Logical; if TRUE, scale dimensions prior to distance
#'   calculation.
#' @return A `wvs_neighbors` object (class inherits from `wvsR`) with
#'   `title`, `country`, `country_name`, `wave`, and `neighbors` (a
#'   data.frame with `iso`, `country`, and `distance`).
#' @export
wvs_neighbors <- function(
  country,
  n = 10,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL,
  scale = TRUE
) {
  data <- wvs_data(path = path)
  iso <- wvs_resolve(country, data)
  distance_matrix <- as.matrix(
    wvs_distances(
      wave = wave,
      dimensions = dimensions,
      select = select,
      strict = strict,
      path = path,
      scale = scale
    )
  )

  if (!iso %in% rownames(distance_matrix)) {
    stop("No complete country mean profile available for ", iso, ".", call. = FALSE)
  }

  distances <- sort(distance_matrix[iso, rownames(distance_matrix) != iso])
  top_n <- utils::head(distances, n)

  out <- list(
    title = "CULTURAL NEIGHBORS",
    country = .wvs_iso(iso),
    wave = wave,
    neighbors = data.frame(
      iso = names(top_n),
      country = vapply(names(top_n), .wvs_iso, character(1)),
      distance = unname(top_n),
      row.names = NULL,
      stringsAsFactors = FALSE
    )
  )
  class(out) <- c("wvs_neighbors", "wvsR")
  out
}

#' Map countries into two-dimensional cultural space
#'
#' Produce a two-dimensional embedding of countries using PCA, MDS,
#' or by selecting two raw dimensions. Returns a `wvs_space` object
#' containing the computed coordinates and plotting metadata.
#'
#' @param method One of `"pca"`, `"mds"`, or `"dimensions"`.
#' @param wave Optional wave number to restrict the data.
#' @param highlight Optional character vector of countries to
#'   highlight on the plot (names or ISO codes).
#' @param dimensions Named list of dimensions (default `dims_all`).
#' @param select Optional vector of dimension names to select.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param path Optional path to the joint data file.
#' @return An object of class `wvs_space` (and `wvsR`) containing
#'   `title`, `wave`, `method`, `axis_labels`, `coordinates`, and
#'   `highlight`.
#' @export
wvs_space <- function(
  method = c("pca", "mds", "dimensions"),
  wave = NULL,
  highlight = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL
) {
  method <- match.arg(method)

  means <- wvs_means(
    wave = wave,
    dimensions = dimensions,
    select = select,
    strict = strict,
    path = path
  )

  mat <- as.matrix(means[, setdiff(names(means), "iso"), drop = FALSE])
  rownames(mat) <- means$iso
  mat <- mat[stats::complete.cases(mat), , drop = FALSE]

  if (nrow(mat) < 3) {
    stop("Fewer than 3 countries have complete dimension scores.", call. = FALSE)
  }

  coords <- switch(
    method,
    pca = {
      if (ncol(mat) < 2) {
        stop("PCA mapping requires at least two dimensions.", call. = FALSE)
      }
      stats::prcomp(scale(mat), scale. = FALSE)$x[, 1:2, drop = FALSE]
    },
    mds = {
      stats::cmdscale(stats::dist(scale(mat)), k = 2)
    },
    dimensions = {
      if (ncol(mat) < 2) {
        stop("For method = 'dimensions', select at least two dimensions.", call. = FALSE)
      }
      mat[, 1:2, drop = FALSE]
    }
  )

  isos <- rownames(coords)
  highlight_iso <- character(0)
  if (!is.null(highlight)) {
    data <- wvs_data(path = path)
    highlight_iso <- vapply(highlight, function(x) {
      tryCatch(wvs_resolve(x, data), error = function(e) NA_character_)
    }, character(1))
    highlight_iso <- highlight_iso[!is.na(highlight_iso) & highlight_iso %in% isos]
  }

  coordinate_names <- if (method == "dimensions") {
    colnames(coords)
  } else if (method == "pca") {
    c("PC1", "PC2")
  } else {
    c("MDS1", "MDS2")
  }

  axis_labels <- if (method == "dimensions") {
    c(dimensions[[coordinate_names[1]]]$label, dimensions[[coordinate_names[2]]]$label)
  } else {
    c(paste0("Dimension 1 (", toupper(method), ")"), paste0("Dimension 2 (", toupper(method), ")"))
  }

  out <- list(
    title = "CULTURAL SPACE",
    wave = wave,
    method = method,
    coordinates = {
      coord_df <- data.frame(
        iso = isos,
        country = vapply(isos, .wvs_iso, character(1)),
        coords,
        row.names = NULL,
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
      names(coord_df) <- c("iso", "country", coordinate_names)
      coord_df
    },
    highlight = highlight_iso,
    axis_labels = axis_labels
  )

  class(out) <- c("wvs_space", "wvsR")
  out
}

#' Plot a `wvs_space` object
#'
#' Draws a two-dimensional cultural map using coordinates returned by
#' `wvs_space()`.
#'
#' @param x A `wvs_space` object as returned by `wvs_space()`.
#' @param ... Additional plotting arguments (ignored).
#' @return The input object invisibly.
#' @export
plot.wvs_space <- function(x, ...) {
  coords <- x$coordinates
  isos <- coords$iso
  highlight_iso <- x$highlight
  coord_cols <- tail(names(coords), 2)

  colors <- ifelse(isos %in% highlight_iso, "#C00000", "#4472C4")
  points <- ifelse(isos %in% highlight_iso, 19, 20)
  sizes <- ifelse(isos %in% highlight_iso, 1.2, 0.8)
  x_vals <- coords[[coord_cols[1]]]
  y_vals <- coords[[coord_cols[2]]]

  xlim_raw <- range(x_vals, na.rm = TRUE)
  ylim_raw <- range(y_vals, na.rm = TRUE)

  x_span <- diff(xlim_raw)
  y_span <- diff(ylim_raw)

  x_pad <- if (is.finite(x_span) && x_span > 0) 0.08 * x_span else 0.5
  y_pad <- if (is.finite(y_span) && y_span > 0) 0.12 * y_span else 0.5

  xlim <- xlim_raw + c(-x_pad, x_pad)
  ylim <- ylim_raw + c(-y_pad, y_pad)

  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par))
  graphics::par(mar = c(5, 6, 4, 4))

  graphics::plot(
    x_vals,
    y_vals,
    col = colors,
    pch = points,
    cex = sizes,
    xlim = xlim,
    ylim = ylim,
    xlab = x$axis_labels[1],
    ylab = x$axis_labels[2],
    main = x$title,
    bty = "n"
  )
  graphics::text(x_vals, y_vals, labels = isos, pos = 3, cex = 0.65, col = colors, xpd = NA)

  subtitle_parts <- c()
  if (!is.null(x$wave)) {
    subtitle_parts <- c(subtitle_parts, sprintf("Wave: %s", x$wave))
  }
  method_label <- if (x$method %in% c("pca", "mds")) toupper(x$method) else .wvs_pretty(x$method)
  subtitle_parts <- c(subtitle_parts, sprintf("Method: %s", method_label))
  if (length(subtitle_parts) > 0) {
    graphics::mtext(paste(subtitle_parts, collapse = "  |  "), side = 3, line = 0.7, cex = 0.95)
  }

  invisible(x)
}

#' Cluster countries into cultural groups
#'
#' Perform k-means clustering on country mean profiles to assign
#' countries to `k` clusters and compute cluster centroids.
#'
#' @param k Number of clusters (default 5).
#' @param wave Optional wave number to restrict the data.
#' @param dimensions Named list of dimensions (default `dims_all`).
#' @param select Optional vector of dimension names to select.
#' @param strict Logical; if TRUE, use strict scoring rules.
#' @param path Optional path to the joint data file.
#' @param seed Integer seed for reproducible clustering.
#' @return A `wvs_clusters` object (class inherits from `wvsR`) with
#'   `title`, `wave`, `k`, `assignments` (data.frame), and
#'   `cluster_means` (list of numeric vectors).
#' @export
wvs_clusters <- function(
  k = 5,
  wave = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL,
  seed = 42
) {
  means <- wvs_means(
    wave = wave,
    dimensions = dimensions,
    select = select,
    strict = strict,
    path = path
  )

  mat <- as.matrix(means[, setdiff(names(means), "iso"), drop = FALSE])
  rownames(mat) <- means$iso
  mat <- mat[stats::complete.cases(mat), , drop = FALSE]

  if (nrow(mat) < k) {
    stop("Only ", nrow(mat), " countries have complete data; k must be smaller.", call. = FALSE)
  }

  set.seed(seed)
  km <- stats::kmeans(scale(mat), centers = k, nstart = 25, iter.max = 100)

  assignments <- data.frame(
    iso = rownames(mat),
    country = vapply(rownames(mat), .wvs_iso, character(1)),
    cluster = unname(km$cluster),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  assignments <- assignments[order(assignments$cluster, assignments$iso), , drop = FALSE]

  cluster_means_list <- lapply(seq_len(k), function(cluster) {
    members <- rownames(mat)[km$cluster == cluster]
    colMeans(mat[members, , drop = FALSE], na.rm = TRUE)
  })
  
  cluster_means <- as.data.frame(do.call(rbind, cluster_means_list))
  cluster_means <- cbind(data.frame(cluster = seq_len(k)), cluster_means)
  rownames(cluster_means) <- NULL

  out <- list(
    title = "CULTURAL CLUSTERS",
    wave = wave,
    k = k,
    assignments = assignments,
    cluster_means = cluster_means
  )
  class(out) <- c("wvs_clusters", "wvsR")
  out
}
