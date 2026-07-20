# wvsR
## Dimensions and Item Definition Functions

#' Create a dimension item specification
#'
#' Construct a list describing a survey item used in a dimension
#' definition. This helper normalizes several calling styles and
#' fills missing metadata from the harmonized item codebook.
#'
#' @param var Character variable name (e.g. "A008").
#' @param label Human-readable label for the item. If numeric and
#'   `original_min`/`original_max` are supplied in the alternate
#'   calling form, `label` may be omitted.
#' @param original_min Optional numeric minimum of the original
#'   response scale.
#' @param original_max Optional numeric maximum of the original
#'   response scale.
#' @param direction Numeric multiplier (1 or -1) indicating whether
#'   higher values indicate more of the dimension (1) or less (-1).
#' @return A named list describing the item.
#' @keywords internal
#' @noRd
wvs_item <- function(var, label = NULL, original_min = NULL, original_max = NULL, direction = NULL) {
  if (is.numeric(label) && !is.null(original_min) && !is.null(original_max)) {
    direction <- original_max
    original_max <- original_min
    original_min <- label
    label <- var
  }

  item_metadata <- get_item_metadata(var)
  if (is.null(label) || identical(label, var)) {
    if (!is.na(item_metadata$label[1])) {
      label <- item_metadata$label[1]
    }
  }
  if (is.null(original_min) && !is.na(item_metadata$min[1])) {
    original_min <- item_metadata$min[1]
  }
  if (is.null(original_max) && !is.na(item_metadata$max[1])) {
    original_max <- item_metadata$max[1]
  }
  if (is.null(direction) && !is.na(item_metadata$direction[1])) {
    direction <- item_metadata$direction[1]
  }
  if (is.null(direction)) direction <- 1

  list(
    var = var,
    label = label,
    original_min = original_min,
    original_max = original_max,
    direction = direction
  )
}

 #' @keywords internal
 #' @noRd
resolve_dimension_items <- function(items) {
  if (is.null(items)) return(list())

  if (is.character(items)) {
    return(lapply(items, wvs_item))
  }

  if (is.numeric(items) && !is.null(names(items))) {
    return(lapply(seq_along(items), function(i) {
      wvs_item(names(items)[i], direction = items[[i]])
    }))
  }

  if (is.list(items)) {
    if (length(items) == 0) return(list())

    if (all(vapply(items, is.character, logical(1)))) {
      return(lapply(unlist(items), wvs_item))
    }

    if (!is.null(names(items)) && all(nzchar(names(items))) && all(vapply(items, is.numeric, logical(1)))) {
      return(lapply(seq_along(items), function(i) {
        wvs_item(names(items)[i], direction = items[[i]])
      }))
    }

    return(lapply(items, function(item) {
      if (is.character(item) && length(item) == 1) {
        return(wvs_item(item))
      }
      if (is.list(item) && !is.null(item$var)) {
        return(item)
      }
      stop("Unsupported item format in dimension definition.", call. = FALSE)
    }))
  }

  stop("Unsupported item format in dimension definition.", call. = FALSE)
}

 #' @keywords internal
 #' @noRd
resolve_dimension <- function(dimension) {
  if (!is.null(dimension$items)) {
    dimension$items <- resolve_dimension_items(dimension$items)
  }
  dimension
}

#' Dimension definitions
#'
#' Predefined dimension definitions used by `wvsR` and examples.
#' @name dims_core
#' @rdname dims_definitions
#' @format A named list of dimension definitions.
#' @export
dims_core <- list(
  Tradition = list(
    label = "Traditional vs Secular-Rational",
    type = "mean",
    items = c("A006", "F063", "F034", "F028", "F118", "F120", "F121", "F122")
  ),

  Survival = list(
    label = "Survival vs Self-Expression",
    type = "mean",
    items = c("A008", "A165", "A173", "A029", "A034", "A035", "E025", "F118")
  )
)

#' @rdname dims_definitions
#' @format A named list of dimension definitions.
#' @export
dims_main <- list(
  Institution = list(
    label = "Institutional Trust",
    type = "mean",
    items = c("E069_01", "E069_02", "E069_04", "E069_06", "E069_07", "E069_08", "E069_11", "E069_12", "E069_17")
  ),

  Moral = list(
    label = "Moral Permissiveness",
    type = "mean",
    items = c("F118", "F119", "F120", "F121", "F122", "F123")
  ),

  Gender = list(
    label = "Gender Equality",
    type = "mean",
    items = c("C001_01", "D059", "D061", "D078", "E233")
  ),

  Civic = list(
    label = "Civic Engagement",
    type = "mean",
    items = c("E026", "E027", "E028", "E025")
  )
)

#' @rdname dims_definitions
#' @format A named list of dimension definitions.
#' @export
dims_extended <- list(
  Political = list(
    label = "Political Engagement",
    type = "mean",
    items = c("A068", "E025", "E026", "E027", "E028")
  ),

  Social = list(
    label = "Social Trust",
    type = "mean",
    items = c("A165", "G007_34_B", "G007_35_B", "G007_36_B")
  ),

  Economic = list(
    label = "Market Orientation",
    type = "mean",
    items = c("E035", "E036", "E037", "E039")
  ),

  Wellbeing = list(
    label = "Subjective Wellbeing",
    type = "mean",
    items = c("A008", "A009", "A170", "A173")
  ),

  Democracy = list(
    label = "Liberal Democracy Support",
    type = "mean",
    items = c("E114", "E116", "E117", "E225", "E226", "E228", "E229")
  )
)

#' @rdname dims_definitions
#' @format A named list of dimension definitions.
#' @export
dims_dev <- list(
  TraditionalSecular = list(
    label = "Traditional vs Secular-Rational", 
    type = "mean", 
    items = c("F063", "G006", "E018", "F120")
  ),

  SurvivalSelfExpression = list(
    label = "Survival vs Self-Expression", 
    type = "mean", 
    items = c("A008", "A165", "F118", "E025")
  ),
  
  Autonomy = list(
    label = "Autonomy", 
    type = "contrast", 
    positive = c("A029", "A039"), 
    negative = c("A040", "A042")
  ),

  Postmaterialism = list(
    label = "Postmaterialism", 
    type = "lookup", 
    vars = c("E001", "E002")
  ),

  LifeSatisfaction = list(
    label = "Life Satisfaction", 
    type = "mean", 
    items = c("A008", "A170", "A009")
  ),

  PersonalAgency = list(
    label = "Personal Agency", 
    type = "mean", 
    items = c("A173", "A029", "A039")
  ),

  Religiosity = list(
    label = "Religiosity", 
    type = "mean", 
    items = c("A006", "F028", "F034", "F050", "F063")
  ),

  SupernaturalBelief = list(
    label = "Supernatural Belief", 
    type = "mean", 
    items = c("F050", "F051", "F053", "F054")
  ),

  SexualPermissiveness = list(
    label = "Sexual Permissiveness", 
    type = "mean", 
    items = c("F118", "F119", "F120", "F121", "F132")
  ),

  EndOfLifePermissiveness = list(
    label = "End-of-life Permissiveness", 
    type = "mean", 
    items = c("F122", "F123")
  ),

  CivicMorality = list(
    label = "Civic Morality", 
    type = "mean", 
    items = c("F114A", "F115", "F116", "F117")
  ),

  PoliticalParticipation = list(
    label = "Political Participation", 
    type = "mean", 
    items = c("E025", "E026", "E027", "E028")
  ),

  PoliticalInterest = list(
    label = "Political Interest", 
    type = "mean", 
    items = c("E023")
  ),

  InstitutionalTrust = list(
    label = "Institutional Trust", 
    type = "mean", 
    items = c("E069_01", "E069_06", "E069_07", "E069_11", "E069_17")
  ),

  DemocraticValues = list(
    label = "Democratic Values", 
    type = "mean", 
    items = c("E117", "E226", "E229", "E233", "E235")
  ),

  EconomicIdeology = list(
    label = "Economic Ideology", 
    type = "mean", 
    items = c("E035", "E036", "E037", "E039")
  ),

  GenderTraditionalism = list(
    label = "Gender Traditionalism", 
    type = "mean", 
    items = c("D059", "D060", "D061", "D078")
  ),

  FilialObligation = list(
    label = "Filial Obligation", 
    type = "mean", 
    items = c("D026_03", "D026_05", "D054")
  ),

  FamilyTraditionalism = list(
    label = "Family Traditionalism", 
    type = "mean", 
    items = c("D081", "D059", "D061")
  ),

  Environmentalism = list(
    label = "Environmentalism", 
    type = "mean", 
    items = c("B008", "A071")
  ),

  WorkEthic = list(
    label = "Work Ethic", 
    type = "mean", 
    items = c("C038", "C039", "C041")
  ),

  NationalAttachment = list(
    label = "National Attachment", 
    type = "mean", 
    items = c("G006", "G255", "G256", "G257")
  ),

  GlobalIdentity = list(
    label = "Global Identity", 
    type = "mean", 
    items = c("G062", "G063")
  ),

  ImmigrationAcceptance = list(
    label = "Immigration Acceptance", 
    type = "mean", 
    items = c("A124_06", "G052")
  ),

  GeneralizedTrust = list(
    label = "Generalized Trust", 
    type = "mean", 
    items = c("A165")
  ),

  OutgroupTrust = list(
    label = "Outgroup Trust", 
    type = "mean", 
    items = c("G007_35_B", "G007_36_B")
  ),

  SecurityOrientation = list(
    label = "Security Orientation", 
    type = "mean", 
    items = c("H009", "H010", "H011")
  )
)

# Combine default and dev dimensions, preserving legacy names for backward compatibility
#' @rdname dims_definitions
#' @format A named list of dimension definitions.
#' @export
dims_all <- c(dims_core, dims_main, dims_extended, dims_dev)

# Return a data.frame listing dimensions and their metadata
#' List available dimensions and metadata
#'
#' Return a data.frame with one row per dimension, including its
#' assigned group (Core/Main/Extended/Dev), label and type where
#' available.
#'
#' @param dimensions Named list of dimension definitions (default
#'   `dims_all`).
#' @return Data.frame with columns `dimension`, `group`, `label`, and
#'   `type`.
#' @export
wvs_dimensions <- function(dimensions = dims_all) {
  groups <- list(
    Core = names(dims_core),
    Main = names(dims_main),
    Extended = names(dims_extended)
  )

  dims <- names(dimensions)
  rows <- lapply(dims, function(nm) {
    grp <- if (nm %in% groups$Core) "Core" else if (nm %in% groups$Main) "Main" else if (nm %in% groups$Extended) "Extended" else "Dev"
    d <- dimensions[[nm]]
    title <- if (!is.null(d$label)) d$label else nm
    type <- if (!is.null(d$type)) d$type else "mean"
    data.frame(dimension = nm, title = title, group = grp, type = type, stringsAsFactors = FALSE)
  })

  if (length(rows) == 0) return(data.frame())
  do.call(rbind, rows)
}
