## Dimensions and item definitions

wvs_item <- function(var, label, original_min = NULL, original_max = NULL, direction = 1) {
  if (is.numeric(label) && !is.null(original_min) && !is.null(original_max)) {
    direction <- original_max
    original_max <- original_min
    original_min <- label
    label <- var
  }

  list(
    var = var,
    label = label,
    original_min = original_min,
    original_max = original_max,
    direction = direction
  )
}

dims_core <- list(
  Tradition = list(
    label = "Traditional vs Secular-Rational",
    items = list(
      wvs_item("A006", 1, 4, 1),
      wvs_item("F063", 1, 10, -1),
      wvs_item("F034", 1, 3, -1),
      wvs_item("F028", 1, 8, 1),
      wvs_item("F118", 1, 10, 1),
      wvs_item("F120", 1, 10, 1),
      wvs_item("F121", 1, 10, 1),
      wvs_item("F122", 1, 10, 1)
    )
  ),

  Survival = list(
    label = "Survival vs Self-Expression",
    items = list(
      wvs_item("A008", 1, 4, -1),
      wvs_item("A165", 1, 2, -1),
      wvs_item("A173", 1, 10, 1),
      wvs_item("A029", 0, 1, 1),
      wvs_item("A034", 0, 1, 1),
      wvs_item("A035", 0, 1, 1),
      wvs_item("E025", 1, 3, -1),
      wvs_item("F118", 1, 10, 1)
    )
  )
)

dims_main <- list(
  Institution = list(
    label = "Institutional Trust",
    items = list(
      wvs_item("E069_01", 1, 4, -1),
      wvs_item("E069_02", 1, 4, -1),
      wvs_item("E069_04", 1, 4, -1),
      wvs_item("E069_06", 1, 4, -1),
      wvs_item("E069_07", 1, 4, -1),
      wvs_item("E069_08", 1, 4, -1),
      wvs_item("E069_11", 1, 4, -1),
      wvs_item("E069_12", 1, 4, -1),
      wvs_item("E069_17", 1, 4, -1)
    )
  ),

  Moral = list(
    label = "Moral Permissiveness",
    items = list(
      wvs_item("F118", 1, 10, 1),
      wvs_item("F119", 1, 10, 1),
      wvs_item("F120", 1, 10, 1),
      wvs_item("F121", 1, 10, 1),
      wvs_item("F122", 1, 10, 1),
      wvs_item("F123", 1, 10, 1)
    )
  ),

  Gender = list(
    label = "Gender Equality",
    items = list(
      wvs_item("C001_01", 1, 5, 1),
      wvs_item("D059", 1, 4, 1),
      wvs_item("D061", 1, 4, 1),
      wvs_item("D078", 1, 4, 1),
      wvs_item("E233", 0, 10, 1)
    )
  ),

  Civic = list(
    label = "Civic Engagement",
    items = list(
      wvs_item("E026", 1, 3, -1),
      wvs_item("E027", 1, 3, -1),
      wvs_item("E028", 1, 3, -1),
      wvs_item("E025", 1, 3, -1)
    )
  )
)

dims_extended <- list(
  Political = list(
    label = "Political Engagement",
    items = list(
      wvs_item("A068", 0, 1, 1),
      wvs_item("E025", 1, 3, -1),
      wvs_item("E026", 1, 3, -1),
      wvs_item("E027", 1, 3, -1),
      wvs_item("E028", 1, 3, -1)
    )
  ),

  Social = list(
    label = "Social Trust",
    items = list(
      wvs_item("A165", 1, 2, -1),
      wvs_item("G007_34_B", 1, 4, -1),
      wvs_item("G007_35_B", 1, 4, -1),
      wvs_item("G007_36_B", 1, 4, -1)
    )
  ),

  Economic = list(
    label = "Market Orientation",
    items = list(
      wvs_item("E035", 1, 10, 1),
      wvs_item("E036", 1, 10, -1),
      wvs_item("E037", 1, 10, -1),
      wvs_item("E039", 1, 10, -1)
    )
  ),

  Wellbeing = list(
    label = "Subjective Wellbeing",
    items = list(
      wvs_item("A008", 1, 4, -1),
      wvs_item("A009", 1, 5, -1),
      wvs_item("A170", 1, 10, 1),
      wvs_item("A173", 1, 10, 1)
    )
  ),

  Democracy = list(
    label = "Liberal Democracy Support",
    items = list(
      wvs_item("E114", 1, 4, 1),
      wvs_item("E116", 1, 4, 1),
      wvs_item("E117", 1, 4, -1),
      wvs_item("E225", 0, 10, -1),
      wvs_item("E226", 0, 10, 1),
      wvs_item("E228", 0, 10, -1),
      wvs_item("E229", 0, 10, 1)
    )
  )
)

dims_all <- c(dims_core, dims_main, dims_extended)

wvs_names <- function(dimensions = dims_all) {
  names(dimensions)
}

wvs_items <- function(dimensions = dims_all) {
  rows <- unlist(
    lapply(names(dimensions), function(dim_name) {
      lapply(dimensions[[dim_name]]$items, function(item) {
        data.frame(
          dimension = dim_name,
          dimension_label = dimensions[[dim_name]]$label,
          variable = item$var,
          item_label = item$label,
          direction = item$direction,
          original_min = item$original_min,
          original_max = item$original_max,
          stringsAsFactors = FALSE
        )
      })
    }),
    recursive = FALSE
  )

  do.call(rbind, rows)
}

wvs_validate <- function(data, dimensions = dims_all) {
  items <- wvs_items(dimensions)
  items$available <- items$variable %in% names(data)

  var_labels <- attr(data, "var.labels")
  if (!is.null(var_labels)) {
    names(var_labels) <- names(data)
    items$source_label <- unname(var_labels[items$variable])
  } else {
    items$source_label <- NA_character_
  }

  observed <- lapply(items$variable, function(var) {
    if (!var %in% names(data)) {
      return(c(observed_min = NA_real_, observed_max = NA_real_))
    }

    values <- suppressWarnings(as.numeric(data[[var]]))
    values <- values[is.finite(values) & values >= 0]
    if (length(values) == 0) {
      return(c(observed_min = NA_real_, observed_max = NA_real_))
    }

    range(values, na.rm = TRUE)
  })
  observed <- do.call(rbind, observed)
  colnames(observed) <- c("observed_min", "observed_max")
  items$observed_min <- observed[, "observed_min"]
  items$observed_max <- observed[, "observed_max"]

  items
}
