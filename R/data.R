# wvsR
## Data Access Functions

wvs_cache <- new.env(parent = emptyenv())

#' Locate the bundled joint dataset or use a provided path
#'
#' Resolve the path to the joint EVS/WVS dataset. If `path` is
#' provided it is validated and returned; otherwise this function
#' searches common locations in the repository, system data, and a
#' remote fallback URL. Returned paths are normalized for Windows.
#'
#' @param path Optional path to a local data file. If provided it must
#'   exist.
#' @return Character scalar with the resolved path to the data file.
#' @keywords internal
#' @noRd
wvs_path <- function(path = NULL) {

  if (!is.null(path)) {
    if (!file.exists(path))
      stop("Data file not found: ", path, call. = FALSE)

    return(normalizePath(path, winslash = "/", mustWork = TRUE))
  }

  # prefer the repository .rds
  filenames <- c("EVS_WVS_Joint_Rrds_v5_0.rds")

  candidates <- unlist(lapply(filenames, function(filename) {
    c(
      file.path(getwd(), "data", filename),
      file.path(dirname(getwd()), "data", filename),
      file.path(dirname(dirname(getwd())), "data", filename),
      system.file("data", filename, package = "wvsR")
    )
  }))

  candidates <- candidates[nzchar(candidates) & file.exists(candidates)]

  if (length(candidates)) return(normalizePath(candidates[[1]], winslash = "/", mustWork = TRUE))

  stop(
    "Data file 'EVS_WVS_Joint_Rrds_v5_0.rds' not found in repository. ",
    "Provide a valid `path` to the RDS file or add the file to the package data.",
    call. = FALSE
  )
}

#' Load the joint EVS/WVS dataset into memory (with caching)
#'
#' Read the joint dataset from a path resolved by `wvs_path()` and
#' return it as an R object. Results are cached in-memory for the
#' lifetime of the R session to avoid repeated I/O.
#'
#' @param path Optional path to a local data file; passed to
#'   `wvs_path()`.
#' @return A data.frame (or tibble) containing the joint dataset.
#' @keywords internal
#' @noRd
wvs_load <- function(path = NULL) {

  resolved_path <- wvs_path(path)

  cache_key <- paste0("joint_data::", resolved_path)

  if (exists(cache_key, envir = wvs_cache, inherits = FALSE)) {
    return(get(cache_key, envir = wvs_cache, inherits = FALSE))
  }

  # read the RDS file
  data <- readRDS(resolved_path)

  assign(cache_key, data, envir = wvs_cache)

  data
}

#' Clear in-memory dataset cache
#'
#' Remove any cached datasets stored by `wvs_load()` from the
#' package internal cache environment.
#' @return Invisibly returns `NULL`.
#' @keywords internal
#' @noRd
wvs_clear <- function() {
  rm(
    list = ls(envir = wvs_cache, all.names = TRUE),
    envir = wvs_cache
  )
  invisible(NULL)
}

#' Subset the joint dataset by country and/or wave
#'
#' Return rows of the joint dataset filtered by `country` and/or
#' `wave`. `country` may be a country name or ISO code and is
#' resolved using `wvs_resolve()`.
#'
#' @param country Optional country name or ISO code to filter by.
#' @param wave Optional wave number to filter by.
#' @param path Optional path to data; passed to `wvs_load()`.
#' @return Filtered data.frame of survey responses.
#' @keywords internal
#' @noRd
wvs_data <- function(country = NULL, wave = NULL, path = NULL) {

  data <- wvs_load(path)

  if (!is.null(country)) {
    iso <- wvs_resolve(country, data)
    data <- data[
      as.character(data$cntry_AN) == iso,
      ,
      drop = FALSE
    ]
  }

  if (!is.null(wave)) {
    data <- data[
      as.integer(data$wave) == as.integer(wave),
      ,
      drop = FALSE
    ]
  }

  if (nrow(data) == 0) {
    stop(
      "No rows matched the requested country/wave filters.",
      call. = FALSE
    )
  }

  data
}

#' List available countries (or info for one or more countries)
#'
#' When called without `countries`, returns a data.frame listing ISO
#' code, display name and number of respondents for each country in
#' the joint dataset (optionally restricted to a specific `wave`).
#' When `countries` is provided, returns a `wvs_countries` object with
#' data for the requested country or countries.
#'
#' @param countries Optional country name(s) or ISO code(s) to query.
#' @param wave Optional wave number to restrict the dataset.
#' @param path Optional path to data; passed to `wvs_load()`.
#' @return A `wvs_countries` object with `title`, `wave`, and `countries`.
#' @export
wvs_countries <- function(countries = NULL, wave = NULL, path = NULL) {

  data <- wvs_data(wave = wave, path = path)

  if (!is.null(countries)) {
    countries <- as.character(countries)
    isos <- vapply(countries, .wvs_resolve, character(1))
    n <- vapply(isos, function(iso) sum(as.character(data$cntry_AN) == iso), integer(1))

    missing <- which(n == 0L)
    if (length(missing)) {
      stop(
        sprintf("Country '%s' (%s) is not available in this dataset.", countries[[missing[1]]], isos[[missing[1]]]),
        call. = FALSE
      )
    }

    countries_df <- data.frame(
      iso = isos,
      country = vapply(isos, .wvs_iso, character(1)),
      n = unname(n),
      stringsAsFactors = FALSE,
      row.names = NULL
    )

    out <- list(
      title = "COUNTRY INFORMATION",
      wave = wave,
      countries = countries_df
    )
    class(out) <- c("wvs_countries", "wvsR")
    return(out)
  }

  countries_df <- stats::aggregate(
    uniqid ~ cntry_AN,
    data = data,
    FUN = length
  )

  names(countries_df) <- c("iso", "n")

  countries_df$country <- vapply(
    countries_df$iso,
    .wvs_iso,
    character(1)
  )

  countries_df <- countries_df[, c("iso", "country", "n")]
  countries_df <- countries_df[order(countries_df$iso), , drop = FALSE]

  out <- list(
    title = "COUNTRY INFORMATION",
    wave = wave,
    countries = countries_df
  )
  class(out) <- c("wvs_countries", "wvsR")
  out
}

# ISO 2-letter country code lookup (name -> code)
.wvs_lookup <- c(
  "Albania"                  = "AL",
  "Algeria"                  = "DZ",
  "Andorra"                  = "AD",
  "Argentina"                = "AR",
  "Armenia"                  = "AM",
  "Australia"                = "AU",
  "Austria"                  = "AT",
  "Azerbaijan"               = "AZ",
  "Bangladesh"               = "BD",
  "Belarus"                  = "BY",
  "Bolivia"                  = "BO",
  "Bosnia"                   = "BA",
  "Bosnia and Herzegovina"   = "BA",
  "Brazil"                   = "BR",
  "Bulgaria"                 = "BG",
  "Canada"                   = "CA",
  "Chile"                    = "CL",
  "China"                    = "CN",
  "Colombia"                 = "CO",
  "Croatia"                  = "HR",
  "Cyprus"                   = "CY",
  "Czech Republic"           = "CZ",
  "Czechia"                  = "CZ",
  "Denmark"                  = "DK",
  "Ecuador"                  = "EC",
  "Egypt"                    = "EG",
  "Estonia"                  = "EE",
  "Ethiopia"                 = "ET",
  "Finland"                  = "FI",
  "France"                   = "FR",
  "Georgia"                  = "GE",
  "Germany"                  = "DE",
  "Great Britain"            = "GB",
  "Greece"                   = "GR",
  "Guatemala"                = "GT",
  "Hong Kong"                = "HK",
  "Hungary"                  = "HU",
  "Iceland"                  = "IS",
  "India"                    = "IN",
  "Indonesia"                = "ID",
  "Iran"                     = "IR",
  "Iraq"                     = "IQ",
  "Italy"                    = "IT",
  "Japan"                    = "JP",
  "Jordan"                   = "JO",
  "Kazakhstan"               = "KZ",
  "Kenya"                    = "KE",
  "Korea"                    = "KR",
  "South Korea"              = "KR",
  "Kuwait"                   = "KW",
  "Kyrgyzstan"               = "KG",
  "Latvia"                   = "LV",
  "Lebanon"                  = "LB",
  "Lithuania"                = "LT",
  "Libya"                    = "LY",
  "Luxembourg"               = "LU",
  "Macau"                    = "MO",
  "Maldives"                 = "MV",
  "Malaysia"                 = "MY",
  "Mexico"                   = "MX",
  "Moldova"                  = "MD",
  "Mongolia"                 = "MN",
  "Montenegro"               = "ME",
  "Morocco"                  = "MA",
  "Myanmar"                  = "MM",
  "Netherlands"              = "NL",
  "New Zealand"              = "NZ",
  "Nicaragua"                = "NI",
  "Nigeria"                  = "NG",
  "North Macedonia"          = "MK",
  "Northern Ireland"         = "NIR",
  "Norway"                   = "NO",
  "Pakistan"                 = "PK",
  "Peru"                     = "PE",
  "Philippines"              = "PH",
  "Poland"                   = "PL",
  "Portugal"                 = "PT",
  "Puerto Rico"              = "PR",
  "Romania"                  = "RO",
  "Russia"                   = "RU",
  "Serbia"                   = "RS",
  "Singapore"                = "SG",
  "Slovakia"                 = "SK",
  "Slovenia"                 = "SI",
  "Spain"                    = "ES",
  "Sweden"                   = "SE",
  "Switzerland"              = "CH",
  "Taiwan"                   = "TW",
  "Tajikistan"               = "TJ",
  "Thailand"                 = "TH",
  "Tunisia"                  = "TN",
  "Turkey"                   = "TR",
  "Ukraine"                  = "UA",
  "United Kingdom"           = "GB",
  "UK"                       = "GB",
  "United States"            = "US",
  "United States of America" = "US",
  "USA"                      = "US",
  "Uruguay"                  = "UY",
  "Uzbekistan"               = "UZ",
  "Venezuela"                = "VE",
  "Vietnam"                  = "VN",
  "Zimbabwe"                 = "ZW"
)

#' Resolve a country argument to its ISO code and validate availability
#'
#' Convert a country name or ISO code to the canonical two-letter
#' ISO code used in the dataset and check that the code is present in
#' the provided dataset (or the joint dataset if none provided).
#'
#' @param country Character name or ISO code for a country.
#' @param data Optional dataset to check availability against.
#' @param path Optional path to data; used when `data` is NULL.
#' @return Upper-case two-letter ISO code as a character scalar.
#' @keywords internal
#' @noRd
wvs_resolve <- function(country, data = NULL, path = NULL) {
  if (is.null(data)) {
    data <- wvs_load(path)
  }

  iso <- .wvs_resolve(country)

  available <- unique(as.character(data$cntry_AN))

  if (!iso %in% available) {
    stop(
      sprintf("Country '%s' (%s) is not available in this dataset.", country, iso),
      call. = FALSE
    )
  }

  iso
}

#' Resolve a country argument to its ISO code
#'
#' This internal helper implements the lookup logic for country
#' resolution. It is not exported.
#'
#' @param x Country name or ISO code.
#' @return Two-letter ISO code (character scalar) or error if not
#'   recognised.
#' @keywords internal
.wvs_resolve <- function(x) {
  x <- trimws(x)
  # Already an ISO code?
  all_codes <- unique(unname(.wvs_lookup))
  if (toupper(x) %in% toupper(all_codes)) {
    return(toupper(x))
  }
  # Try case-insensitive name match
  idx <- match(tolower(x), tolower(names(.wvs_lookup)))
  if (!is.na(idx)) {
    return(.wvs_lookup[[idx]])
  }
  stop(sprintf("Country not recognised: '%s'.\nUse wvs_data() to see available countries.", x))
}

#' Return a country's display name from an ISO code
#'
#' Translate a two-letter ISO code to the display name used in the
#' package's lookup table. This is an internal helper and not
#' exported.
#'
#' @param code Two-letter ISO code.
#' @return Country display name or the input code if unknown.
#' @keywords internal
.wvs_iso <- function(code) {
  code <- toupper(code)
  idx <- match(code, .wvs_lookup)
  if (!is.na(idx)) names(.wvs_lookup)[idx] else code
}
