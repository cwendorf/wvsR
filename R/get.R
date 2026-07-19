# wvsR
## Codebook Lookup Functions

#' Retrieve human-readable variable label(s)
#'
#' @param v Character vector of variable names.
#' @return Character vector of labels corresponding to `v`.
#' @keywords internal
get_label <- function(v) {
  i <- match(v, rownames(.wvs_codebook))
  .wvs_codebook$label[i]
}

#' Retrieve group/category for variable(s)
#'
#' @param v Character vector of variable names.
#' @return Character vector of group names corresponding to `v`.
#' @keywords internal
get_group <- function(v) {
  i <- match(v, rownames(.wvs_codebook))
  .wvs_codebook$group[i]
}

#' Retrieve item-level minimum values
#'
#' @param v Character vector of variable names.
#' @return Numeric vector of minimum values.
#' @keywords internal
get_item_min <- function(v) {
  i <- match(v, rownames(.wvs_codebook))
  .wvs_codebook$min[i]
}

#' Retrieve item-level maximum values
#'
#' @param v Character vector of variable names.
#' @return Numeric vector of maximum values.
#' @keywords internal
get_item_max <- function(v) {
  i <- match(v, rownames(.wvs_codebook))
  .wvs_codebook$max[i]
}

#' Retrieve item-level default direction multipliers
#'
#' @param v Character vector of variable names.
#' @return Numeric vector of direction multipliers.
#' @keywords internal
get_item_direction <- function(v) {
  i <- match(v, rownames(.wvs_codebook))
  .wvs_codebook$direction[i]
}

#' Retrieve item-level metadata for one or more variables
#'
#' @param v Character vector of variable names.
#' @return Data.frame with columns `var`, `label`, `min`, `max`, and `direction`.
#' @keywords internal
get_item_metadata <- function(v) {
  i <- match(v, rownames(.wvs_codebook))
  data.frame(
    var = v,
    label = .wvs_codebook$label[i],
    min = .wvs_codebook$min[i],
    max = .wvs_codebook$max[i],
    direction = .wvs_codebook$direction[i],
    stringsAsFactors = FALSE
  )
}

#' Get variables in a codebook group
#'
#' @param g Character scalar specifying the group name.
#' @return Character vector of variable names in the group.
#' @keywords internal
get_vars <- function(g) {
  rownames(.wvs_codebook)[.wvs_codebook$group == g]
}
