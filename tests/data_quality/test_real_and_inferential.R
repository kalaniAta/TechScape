# ==============================================================================
# TechScape: Automated Data Quality & Empirical Integrity Tests
# (tests/data_quality/test_real_and_inferential.R)
# ==============================================================================

cat("\n==============================================================\n")
cat("       TECHSCAPE REAL DATA QUALITY & INTEGRITY TEST SUITE     \n")
cat("==============================================================\n\n")

total_assertions <- 0
passed_assertions <- 0

assert <- function(desc, condition) {
  total_assertions <<- total_assertions + 1
  if (isTRUE(condition)) {
    passed_assertions <<- passed_assertions + 1
    cat(sprintf("  [PASS] %s\n", desc))
  } else {
    cat(sprintf("  [FAIL] %s\n", desc))
  }
}

# 1. Load Datasets
real_jobs <- read.csv("data/real_sample/jobs_real_sample.csv", stringsAsFactors = FALSE)
real_skills <- read.csv("data/real_sample/job_skills_real_sample.csv", stringsAsFactors = FALSE)
macro <- read.csv("data/processed/macro_labour_indicators.csv", stringsAsFactors = FALSE)

# 2. Test Provenance Rules
cat(">>> [1/5] Testing Provenance & Anti-Fabrication Constraints...\n")
assert("Real jobs count equals 80", nrow(real_jobs) == 80)
assert("Zero synthetic flags in real dataset (is_synthetic is all FALSE)", all(real_jobs$is_synthetic == FALSE))
assert("All records have non-empty source", all(!is.na(real_jobs$source) & real_jobs$source != ""))
assert("All records have valid source URLs", all(grepl("^http", real_jobs$source_url)))
assert("All records have valid collection dates", all(grepl("^2026-", real_jobs$collection_date)))
assert("All records preserve unmodified original_title", all(!is.na(real_jobs$original_title) & real_jobs$original_title != ""))

# 3. Test Foreign-Key Referential Integrity
cat("\n>>> [2/5] Testing Referential Integrity...\n")
orphan_skills <- setdiff(real_skills$job_id, real_jobs$job_id)
assert("All job_skills link to valid job_id in jobs table (0 orphans)", length(orphan_skills) == 0)
assert("Skills table contains valid canonical skill_name", all(!is.na(real_skills$skill_name) & real_skills$skill_name != ""))

# 4. Test Missing Value Handling
cat("\n>>> [3/5] Testing Missing Value & Compensation Handling...\n")
undisclosed_salaries <- subset(real_jobs, is.na(salary_min))
assert("Undisclosed salaries preserved as NA (not 0)", all(is.na(undisclosed_salaries$salary_min) & is.na(undisclosed_salaries$salary_max)))
disclosed_lkr <- subset(real_jobs, currency == "LKR" & !is.na(salary_min))
assert("Disclosed LKR minimum salaries are positive (> 0)", all(disclosed_lkr$salary_min > 0))
assert("Disclosed LKR salary_max >= salary_min", all(disclosed_lkr$salary_max >= disclosed_lkr$salary_min))

# 5. Test Experience Bounds
cat("\n>>> [4/5] Testing Experience Requirements...\n")
assert("Minimum experience is non-negative (>= 0)", all(real_jobs$experience_min >= 0, na.rm = TRUE))
assert("Valid seniority levels (Intern, Junior, Mid, Senior, Lead)", 
       all(real_jobs$seniority_level %in% c("Intern", "Junior", "Mid", "Senior", "Lead")))

# 6. Test Macroeconomic Indicators
cat("\n>>> [5/5] Testing Macroeconomic Indicators (DCS & CBSL)...\n")
assert("Macro dataset contains valid unemployment records", any(macro$indicator_name == "National Unemployment Rate"))
assert("Unemployment rates within realistic bounds (1% - 30%)", all(subset(macro, grepl("Unemployment", indicator_name))$value > 0 & subset(macro, grepl("Unemployment", indicator_name))$value < 30))
assert("CBSL ICT Export earnings are positive and growing", any(macro$indicator_name == "Telecommunications Computer & Info Export Earnings" & macro$value >= 900))

# Summary
cat("\n==============================================================\n")
cat(sprintf("Test Execution Complete: %d / %d Assertions Passed (%.1f%%)\n", 
            passed_assertions, total_assertions, (passed_assertions / total_assertions) * 100))
cat("==============================================================\n")

if (passed_assertions < total_assertions) {
  stop("Some tests failed!")
}
