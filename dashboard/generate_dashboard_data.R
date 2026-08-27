# ==============================================================================
# TechScape: Dashboard Data Exporter (dashboard/generate_dashboard_data.R)
# ==============================================================================
# Generates structured JSON payload from verified real and macroeconomic datasets
# for the interactive dashboard frontend using pure base R.
# ==============================================================================

jobs <- read.csv("data/processed/jobs_real_transformed.csv", stringsAsFactors = FALSE)
skills <- read.csv("data/processed/job_skills_real_transformed.csv", stringsAsFactors = FALSE)
macro <- read.csv("data/processed/macro_labour_indicators.csv", stringsAsFactors = FALSE)

# Helper function to serialize any R value to valid JSON
to_json_val <- function(val) {
  if (is.null(val) || (length(val) == 1 && is.na(val))) {
    return("null")
  }
  if (is.logical(val)) {
    return(ifelse(val, "true", "false"))
  }
  if (is.numeric(val)) {
    if (is.nan(val) || is.infinite(val)) return("null")
    return(format(val, scientific = FALSE, trim = TRUE))
  }
  # String escaping: backslash, quotes, newlines, tabs
  s <- as.character(val)
  s <- gsub("\\\\", "\\\\\\\\", s)
  s <- gsub('"', '\\\\"', s)
  s <- gsub("\r", "", s)
  s <- gsub("\n", "\\\\n", s)
  s <- gsub("\t", "\\\\t", s)
  return(paste0('"', s, '"'))
}

row_to_json <- function(row) {
  keys <- names(row)
  pairs <- vapply(keys, function(k) {
    paste0('"', k, '": ', to_json_val(row[[k]]))
  }, FUN.VALUE = character(1))
  paste0("{", paste(pairs, collapse = ", "), "}")
}

df_to_json <- function(df) {
  if (nrow(df) == 0) return("[]")
  rows <- lapply(seq_len(nrow(df)), function(i) as.list(df[i, , drop = FALSE]))
  json_rows <- vapply(rows, row_to_json, FUN.VALUE = character(1))
  paste0("[\n  ", paste(json_rows, collapse = ",\n  "), "\n]")
}

# Construct the JS payload
json_str <- sprintf(
  "// TechScape Empirical Data Bundle (Auto-generated)\nwindow.TECHSCAPE_DATA = {\n  jobs: %s,\n  skills: %s,\n  macro: %s\n};\n",
  df_to_json(jobs),
  df_to_json(skills),
  df_to_json(macro)
)

writeLines(json_str, "dashboard/data.js")
cat("✅ Dashboard data bundle successfully generated at `dashboard/data.js`!\n")
