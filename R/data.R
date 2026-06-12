# Data access functions

wvs_cache <- new.env(parent = emptyenv())

wvs_path <- function(path = NULL) {

  if (!is.null(path)) {
    if (!file.exists(path))
      stop("Data file not found: ", path, call. = FALSE)

    return(normalizePath(path, winslash = "/", mustWork = TRUE))
  }

  filename <- "EVS_WVS_Joint_Rrds_v5_0.rds"

  candidates <- c(
    file.path(getwd(), "data", filename),
    file.path(dirname(getwd()), "data", filename),
    file.path(dirname(dirname(getwd())), "data", filename),
    system.file("data", filename, package = "wvsR")
  )

  candidates <- candidates[nzchar(candidates) & file.exists(candidates)]

  if (length(candidates))
    return(normalizePath(candidates[[1]], winslash = "/", mustWork = TRUE))

  cache_file <- file.path(tempdir(), filename)

  if (!file.exists(cache_file)) {
    utils::download.file(
      "https://github.com/cwendorf/wvsR/raw/main/data/EVS_WVS_Joint_Rrds_v5_0.rds",
      cache_file,
      mode = "wb"
    )
  }

  cache_file
}

wvs_load_joint <- function(path = NULL) {

  resolved_path <- wvs_path(path)

  cache_key <- paste0("joint_data::", resolved_path)

  if (exists(cache_key, envir = wvs_cache, inherits = FALSE)) {
    return(get(cache_key, envir = wvs_cache, inherits = FALSE))
  }

  data <- readRDS(resolved_path)

  assign(cache_key, data, envir = wvs_cache)

  data
}

wvs_clear_cache <- function() {
  rm(
    list = ls(envir = wvs_cache, all.names = TRUE),
    envir = wvs_cache
  )
  invisible(NULL)
}

wvs_data <- function(country = NULL, wave = NULL, path = NULL) {

  data <- wvs_load_joint(path)

  if (!is.null(country)) {
    iso <- wvs_resolve_country(country, data)
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

wvs_countries <- function(wave = NULL, path = NULL) {

  data <- wvs_data(wave = wave, path = path)

  countries <- stats::aggregate(
    uniqid ~ cntry_AN,
    data = data,
    FUN = length
  )

  names(countries) <- c("iso", "n")

  countries$country <- vapply(
    countries$iso,
    .iso_to_name,
    character(1)
  )

  countries <- countries[, c("iso", "country", "n")]

  countries[order(countries$iso), , drop = FALSE]
}

# ISO 2-letter country code lookup (name -> code)
.country_lookup <- c(
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

# Resolve a country argument to its ISO code
wvs_resolve_country <- function(country, data = NULL, path = NULL) {
  if (is.null(data)) {
    data <- wvs_load_joint(path)
  }

  iso <- .resolve_country(country)

  available <- unique(as.character(data$cntry_AN))

  if (!iso %in% available) {
    stop(
      sprintf("Country '%s' (%s) is not available in this dataset.", country, iso),
      call. = FALSE
    )
  }

  iso
}

# Resolve a country argument to its ISO code
.resolve_country <- function(x) {
  x <- trimws(x)
  # Already an ISO code?
  all_codes <- unique(unname(.country_lookup))
  if (toupper(x) %in% toupper(all_codes)) {
    return(toupper(x))
  }
  # Try case-insensitive name match
  idx <- match(tolower(x), tolower(names(.country_lookup)))
  if (!is.na(idx)) {
    return(.country_lookup[[idx]])
  }
  stop(sprintf("Country not recognised: '%s'.\nUse wvs_data() to see available countries.", x))
}

# Return a country's display name from an ISO code
.iso_to_name <- function(code) {
  code <- toupper(code)
  idx <- match(code, .country_lookup)
  if (!is.na(idx)) names(.country_lookup)[idx] else code
}

wvs_country <- function(country, wave = NULL, path = NULL) {
  data <- wvs_data(wave = wave, path = path)

  iso <- .resolve_country(country)

  n <- sum(as.character(data$cntry_AN) == iso)

  if (n == 0) {
    stop(
      sprintf("Country '%s' (%s) is not available in this dataset.", country, iso),
      call. = FALSE
    )
  }

  data.frame(
    iso = iso,
    country = .iso_to_name(iso),
    n = n,
    row.names = NULL
  )
}

wvs_variables <- function(dimensions = dims_all, path = NULL) {
  data <- wvs_load_joint(path)
  wvs_validate(data, dimensions)
}
