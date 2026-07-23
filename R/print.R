# wvsR
## Table Formatting Functions

#' Format a results data.frame for printing
#'
#' Internal helper that formats numeric columns with a fixed number
#' of digits and rounds sample sizes without decimal places. Returns
#' a character-formatted data.frame for consistent printing.
#'
#' @param results A data.frame or matrix of results to format.
#' @param digits Number of digits to display for numeric columns.
#' @return A data.frame of character columns suitable for printing.
#' @keywords internal
.wvs_frame <- function(results, digits = 3) {
  df <- as.data.frame(results)

  df[] <- lapply(names(df), function(col) {
    x <- df[[col]]

    if (col == "n" && is.numeric(x)) {
      format(round(x, 0), trim = TRUE)
    } else if (is.numeric(x)) {
      format(round(x, digits), nsmall = digits, trim = TRUE)
    } else {
      x
    }
  })

  names(df) <- .wvs_pretty(names(results))
  df
}

#' Convert internal result column names to pretty labels for printing
#'
#' This helper converts internal table column names such as `iso`, `diff`,
#' and `n` to tidy printing labels like `ISO`, `Diff`, and `N`.
#'
#' @param names Character vector of internal column names.
#' @return Character vector of pretty column labels.
#' @keywords internal
.wvs_pretty <- function(names) {
  mapping <- c(
    iso = "ISO",
    country = "Country",
    cluster = "Cluster",
    dimension = "Dimension",
    label = "Label",
    mean = "Mean",
    lower = "LL",
    upper = "UL",
    diff = "Diff",
    d = "d",
    n = "N",
    distance = "Distance",
    wave = "Wave"
  )

  vapply(names, function(name) {
    mapped_value <- mapping[name]
    if (!is.na(mapped_value) && nzchar(mapped_value)) {
      mapped_value
    } else {
      pretty <- gsub("_", " ", name)
      pretty <- gsub("([a-z])([A-Z])", "\\1 \\2", pretty)
      if (nzchar(pretty)) {
        paste0(toupper(substring(pretty, 1, 1)), substring(pretty, 2))
      } else {
        pretty
      }
    }
  }, character(1), USE.NAMES = FALSE)
}

#' Convert a method name to its printable label
#'
#' @param method Character scalar method name.
#' @return Printable method label.
#' @keywords internal
.wvs_method_label <- function(method) {
  if (method %in% c("pca", "mds")) {
    toupper(method)
  } else {
    .wvs_pretty(method)
  }
}

#' Print a standard wvsR header
#'
#' @param x A `wvsR` object.
#' @keywords internal
.wvs_print_header <- function(x) {
  cat(x$title, "\n", sep = "")

  subtitle_parts <- character(0)
  if (!is.null(x$country)) {
    subtitle_parts <- c(subtitle_parts, sprintf("Country: %s", x$country))
  }
  if (!is.null(x$countries) && !is.data.frame(x$countries) && length(x$countries) >= 2) {
    subtitle_parts <- c(subtitle_parts, sprintf("Countries: %s vs. %s", x$countries[1], x$countries[2]))
  }
  if (!is.null(x$wave)) {
    subtitle_parts <- c(subtitle_parts, sprintf("Wave: %s", x$wave))
  }
  if (!is.null(x$method)) {
    subtitle_parts <- c(subtitle_parts, sprintf("Method: %s", .wvs_method_label(x$method)))
  }
  if (!is.null(x$k)) {
    subtitle_parts <- c(subtitle_parts, sprintf("Clusters: %s", x$k))
  }

  if (length(subtitle_parts) > 0) {
    cat(paste0(subtitle_parts, "\n"), sep = "")
  }
  cat("\n")
}

#' Print a formatted table section
#'
#' @param title Section title.
#' @param value Data frame or matrix to print.
#' @keywords internal
.wvs_print_section <- function(title, value) {
  cat(title, "\n\n", sep = "")
  print(.wvs_frame(value[, names(value) != "label", drop = FALSE]))
}

#' Print method for wvsR result objects
#'
#' S3 `print` method for objects produced by the wvsR estimation and
#' comparison functions. Tables are formatted consistently and other
#' components (title, country, wave) are printed in a readable form.
#'
#' @param x An object inheriting from class `wvsR`.
#' @param ... Additional arguments (ignored).
#' @keywords internal
#' @noRd
print.wvsR <- function(x, ...) {
  cat("\n")
  on.exit(cat("\n"), add = TRUE)

  .wvs_print_header(x)

  if (!is.null(x$means1) && !is.null(x$means2)) {
    cat(x$countries[1], "\n\n", sep = "")
    print(.wvs_frame(x$means1[, names(x$means1) != "label", drop = FALSE]))
    cat("\n")
    cat(x$countries[2], "\n\n", sep = "")
    print(.wvs_frame(x$means2[, names(x$means2) != "label", drop = FALSE]))
    return(invisible(x))
  }

  if (!is.null(x$countries) && is.data.frame(x$countries)) {
    print(.wvs_frame(x$countries[, names(x$countries) != "label", drop = FALSE]))
    return(invisible(x))
  }

  if (!is.null(x$assignments)) {
    .wvs_print_section("Country Assignments", x$assignments)
  }

  if (!is.null(x$cluster_means)) {
    if (!is.null(x$assignments)) {
      cat("\n")
    }
    .wvs_print_section("Cluster Centers", x$cluster_means)
  }

  if (!is.null(x$difference)) {
    print(.wvs_frame(x$difference[, names(x$difference) != "label", drop = FALSE]))
    return(invisible(x))
  }

  if (!is.null(x$means)) {
    print(.wvs_frame(x$means[, names(x$means) != "label", drop = FALSE]))
    return(invisible(x))
  }

  if (!is.null(x$neighbors)) {
    print(.wvs_frame(x$neighbors[, names(x$neighbors) != "label", drop = FALSE]))
    return(invisible(x))
  }

  if (!is.null(x$coordinates)) {
    print(.wvs_frame(x$coordinates[, names(x$coordinates) != "label", drop = FALSE]))
    return(invisible(x))
  }

  invisible(x)
}

#' Display a compact summary of a wvsR object
#'
#' A lightweight `str` method for `wvsR` objects so RStudio and other
#' interactive displays show a concise overview instead of the raw list.
#'
#' @param object A `wvsR` object.
#' @param ... Additional arguments passed to `str` (ignored).
#' @keywords internal
#' @noRd
str.wvsR <- function(object, ...) {
  cat("<wvsR> ", paste(class(object), collapse = ", "), "\n", sep = "")
  if (!is.null(object$title)) {
    cat("Title: ", object$title, "\n", sep = "")
  }
  if (!is.null(object$country)) {
    cat("Country: ", object$country, "\n", sep = "")
  }
  if (!is.null(object$countries) && is.data.frame(object$countries)) {
    cat("Countries: ", nrow(object$countries), " rows\n", sep = "")
  }
  if (!is.null(object$wave)) {
    cat("Wave: ", object$wave, "\n", sep = "")
  }
  if (!is.null(object$method)) {
    cat("Method: ", .wvs_method_label(object$method), "\n", sep = "")
  }
  if (!is.null(object$k)) {
    cat("Clusters: ", object$k, "\n", sep = "")
  }

  components <- setdiff(names(object), c("title", "country", "countries", "wave", "method", "k"))
  if (length(components) > 0L) {
    cat("Components:\n")
    for (name in components) {
      value <- object[[name]]
      label <- if (is.data.frame(value)) {
        paste0("", name, " [", nrow(value), " x ", ncol(value), "]")
      } else if (is.atomic(value) && length(value) == 1L) {
        paste0(name, ": ", format(value))
      } else {
        paste0(name, " [", typeof(value), " length=", length(value), "]")
      }
      cat("  ", label, "\n", sep = "")
    }
  }

  invisible(object)
}
