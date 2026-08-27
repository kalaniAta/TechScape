# ==============================================================================
# TechScape: Dashboard Data Exporter (dashboard/generate_dashboard_data.R)
# ==============================================================================
# Generates structured JSON payload from verified real and macroeconomic datasets
# for the interactive dashboard frontend.
# ==============================================================================

jobs <- read.csv("data/processed/jobs_real_transformed.csv", stringsAsFactors = FALSE)
skills <- read.csv("data/processed/job_skills_real_transformed.csv", stringsAsFactors = FALSE)
macro <- read.csv("data/processed/macro_labour_indicators.csv", stringsAsFactors = FALSE)

# Clean NA values to null in R lists
jobs_list <- lapply(1:nrow(jobs), function(i) {
  row <- as.list(jobs[i, ])
  lapply(row, function(val) if (is.na(val)) NULL else val)
})

skills_list <- lapply(1:nrow(skills), function(i) {
  row <- as.list(skills[i, ])
  lapply(row, function(val) if (is.na(val)) NULL else val)
})

macro_list <- lapply(1:nrow(macro), function(i) {
  row <- as.list(macro[i, ])
  lapply(row, function(val) if (is.na(val)) NULL else val)
})

# Convert to JSON using base R
json_str <- sprintf(
  "// TechScape Empirical Data Bundle (Auto-generated)\nwindow.TECHSCAPE_DATA = {\n  jobs: %s,\n  skills: %s,\n  macro: %s\n};\n",
  # Manual JSON formatting for safety in base R
  paste0("[", paste(sapply(jobs_list, function(x) {
    keys <- names(x)
    pairs <- sapply(keys, function(k) {
      val <- x[[k]]
      if (is.null(val)) sprintf('"%s": null', k)
      else if (is.numeric(val)) sprintf('"%s": %s', k, val)
      else if (is.logical(val)) sprintf('"%s": %s', k, ifelse(val, "true", "false"))
      else sprintf('"%s": %s', k, jsonlite_escape <- gsub('"', '\\\\"', paste0('"', val, '"')))
    })
    paste0("{", paste(pairs, collapse = ","), "}")
  }), collapse = ",\n"), "]"),
  paste0("[", paste(sapply(skills_list, function(x) {
    keys <- names(x)
    pairs <- sapply(keys, function(k) {
      val <- x[[k]]
      if (is.null(val)) sprintf('"%s": null', k)
      else if (is.numeric(val)) sprintf('"%s": %s', k, val)
      else if (is.logical(val)) sprintf('"%s": %s', k, ifelse(val, "true", "false"))
      else sprintf('"%s": %s', k, gsub('"', '\\\\"', paste0('"', val, '"')))
    })
    paste0("{", paste(pairs, collapse = ","), "}")
  }), collapse = ",\n"), "]"),
  paste0("[", paste(sapply(macro_list, function(x) {
    keys <- names(x)
    pairs <- sapply(keys, function(k) {
      val <- x[[k]]
      if (is.null(val)) sprintf('"%s": null', k)
      else if (is.numeric(val)) sprintf('"%s": %s', k, val)
      else if (is.logical(val)) sprintf('"%s": %s', k, ifelse(val, "true", "false"))
      else sprintf('"%s": %s', k, gsub('"', '\\\\"', paste0('"', val, '"')))
    })
    paste0("{", paste(pairs, collapse = ","), "}")
  }), collapse = ",\n"), "]")
)

writeLines(json_str, "dashboard/data.js")
cat("✅ Dashboard data bundle generated at `dashboard/data.js`!\n")
