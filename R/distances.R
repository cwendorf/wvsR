## Cultural Distance Functions

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
  iso <- wvs_resolve_country(country, data)
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
    country = iso,
    wave = wave,
    neighbors = data.frame(
      iso = names(top_n),
      distance = unname(top_n),
      row.names = NULL
    )
  )
  class(out) <- c("wvs_neighbors", "wvsR")
  out
}

wvs_map <- function(
  method = c("pca", "mds", "dimensions"),
  wave = NULL,
  highlight = NULL,
  dimensions = dims_all,
  select = NULL,
  strict = FALSE,
  path = NULL,
  x_dimension = NULL,
  y_dimension = NULL
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
      if (is.null(x_dimension)) x_dimension <- colnames(mat)[1]
      if (is.null(y_dimension)) y_dimension <- colnames(mat)[2]
      if (is.null(x_dimension) || is.null(y_dimension)) {
        stop("For method = 'dimensions', supply two dimensions or select at least two.", call. = FALSE)
      }
      if (!x_dimension %in% colnames(mat)) {
        stop("x_dimension is not available in the selected dimensions: ", x_dimension, call. = FALSE)
      }
      if (!y_dimension %in% colnames(mat)) {
        stop("y_dimension is not available in the selected dimensions: ", y_dimension, call. = FALSE)
      }
      as.matrix(mat[, c(x_dimension, y_dimension), drop = FALSE])
    }
  )

  isos <- rownames(coords)
  highlight_iso <- character(0)
  if (!is.null(highlight)) {
    data <- wvs_data(path = path)
    highlight_iso <- vapply(highlight, function(x) {
      tryCatch(wvs_resolve_country(x, data), error = function(e) NA_character_)
    }, character(1))
    highlight_iso <- highlight_iso[!is.na(highlight_iso) & highlight_iso %in% isos]
  }

  colors <- ifelse(isos %in% highlight_iso, "#C00000", "#4472C4")
  points <- ifelse(isos %in% highlight_iso, 19, 20)
  sizes <- ifelse(isos %in% highlight_iso, 1.2, 0.8)

  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par))
  graphics::par(mar = c(4, 4, 3, 2))

  axis_labels <- if (method == "dimensions") {
    selected_dims <- if (is.null(select)) dimensions else dimensions[select]
    c(
      selected_dims[[colnames(coords)[1]]]$label,
      selected_dims[[colnames(coords)[2]]]$label
    )
  } else {
    c(paste0("Dimension 1 (", toupper(method), ")"), paste0("Dimension 2 (", toupper(method), ")"))
  }

  graphics::plot(
    coords[, 1],
    coords[, 2],
    col = colors,
    pch = points,
    cex = sizes,
    xlab = axis_labels[1],
    ylab = axis_labels[2],
    main = "Cultural Landscape Map"
  )
  graphics::text(coords[, 1], coords[, 2], labels = isos, pos = 3, cex = 0.65, col = colors)

  out <- as.data.frame(coords)
  names(out) <- c("dim1", "dim2")
  out$iso <- rownames(coords)
  out <- out[, c("iso", "dim1", "dim2")]
  invisible(out)
}

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
    cluster = unname(km$cluster),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  assignments <- assignments[order(assignments$cluster, assignments$iso), , drop = FALSE]

  cluster_means <- lapply(seq_len(k), function(cluster) {
    members <- rownames(mat)[km$cluster == cluster]
    colMeans(mat[members, , drop = FALSE], na.rm = TRUE)
  })

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
