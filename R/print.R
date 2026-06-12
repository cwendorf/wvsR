## Table Formatting

.formatFrame <- function(results, digits = 3) {
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

  names(df) <- names(results)
  df
}

print.wvsR <- function(x, ...) {
  for (nm in names(x)) {
    cat("\n")
    if (nm == "means1") {cat(x$countries[[1]], "\n\n")}
    else if (nm == "means2") {cat(x$countries[[2]], "\n\n")}
    value <- x[[nm]]
    if (is.data.frame(value) || is.matrix(value)) {
      print(.formatFrame(value[, names(value) != "label", drop = FALSE]))
    } else {
      if (nm =="country") {cat("Country: ", value)}
      else if (nm == "wave" && !is.null(value)) {cat("Wave:", value, "\n")}
      else if (nm == "countries") {cat(sprintf("Countries: %s vs. %s", x$countries[1], x$countries[2]))}
      else {cat(as.character(value))}
    }
  } 
  cat("\n")
}

