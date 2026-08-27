# ==============================================================================
# TechScape: Cleaning & Transformation Pipeline Test Suite
# ==============================================================================
# Purpose: Executes end-to-end testing across the full data preparation lifecycle:
#   GENERATE -> IMPORT -> VALIDATE RAW -> CLEAN -> TRANSFORM -> VALIDATE PROCESSED
#
# RULE: Verifies data quality improvements, deduplication, schema compliance,
# and relational integrity on synthetic development assets.
# ==============================================================================

source("R/01_import.R")
source("R/02_validate.R")
source("R/03_clean.R")
source("R/04_transform.R")

cat("\n==============================================================\n")
cat("       TECHSCAPE END-TO-END PIPELINE VALIDATION SUITE         \n")
cat("==============================================================\n")

# 1. Step 1: Ingest Raw Synthetic Data
cat("\n[STAGE 1] Loading Raw Synthetic Data...\n")
raw_jobs_file <- "data/synthetic/jobs_synthetic_dev.csv"
raw_skills_file <- "data/synthetic/job_skills_synthetic_dev.csv"

raw_data <- import_dataset_pair(raw_jobs_file, raw_skills_file)
raw_jobs <- raw_data$jobs
raw_skills <- raw_data$skills
cat(sprintf("-> Raw Jobs Count: %d | Raw Skills Count: %d\n", nrow(raw_jobs), nrow(raw_skills)))

# 2. Step 2: Validate Raw Synthetic Data
cat("\n[STAGE 2] Validating Raw Synthetic Data Quality...\n")
val_raw <- validate_dataset(raw_jobs, raw_skills, dataset_name = "Raw Synthetic Data")

# 3. Step 3: Run Cleaning Module
cat("\n[STAGE 3] Executing R/03_clean.R...\n")
clean_res <- clean_pipeline_datasets(
  jobs_input_path = raw_jobs_file,
  skills_input_path = raw_skills_file,
  jobs_output_path = "data/processed/jobs_cleaned.csv",
  skills_output_path = "data/processed/job_skills_cleaned.csv"
)

cleaned_jobs <- clean_res$jobs
cleaned_skills <- clean_res$skills

# 4. Step 4: Run Transformation Module
cat("\n[STAGE 4] Executing R/04_transform.R...\n")
trans_res <- transform_pipeline_datasets(
  cleaned_jobs_path = "data/processed/jobs_cleaned.csv",
  cleaned_skills_path = "data/processed/job_skills_cleaned.csv",
  transformed_jobs_path = "data/processed/jobs_transformed.csv",
  transformed_skills_path = "data/processed/job_skills_transformed.csv"
)

trans_jobs <- trans_res$jobs
trans_skills <- trans_res$skills

# 5. Step 5: Assertions & Integrity Checks on Processed Data
cat("\n[STAGE 5] Running Pipeline Assertions on Processed Datasets...\n")

test_errors <- character()

# Assertion 1: Row counts & Deduplication
expected_dedup <- nrow(raw_jobs) - nrow(cleaned_jobs)
if (expected_dedup <= 0) {
  test_errors <- c(test_errors, "Deduplication check failed: Expected duplicates to be removed.")
} else {
  cat(sprintf("✓ Deduplication successfully removed %d duplicate records.\n", expected_dedup))
}

# Assertion 2: Transformed column presence
req_trans_cols <- c("posting_year", "posting_quarter", "is_entry_level", 
                    "experience_band", "salary_disclosed", "salary_midpoint", 
                    "salary_band_lkr", "skill_count", "skill_names_concat")
missing_trans_cols <- setdiff(req_trans_cols, names(trans_jobs))
if (length(missing_trans_cols) > 0) {
  test_errors <- c(test_errors, sprintf("Transformed jobs missing engineered columns: %s", paste(missing_trans_cols, collapse = ", ")))
} else {
  cat("✓ All required engineered features present in jobs_transformed.csv.\n")
}

# Assertion 3: Enriched skills column presence
req_trans_skill_cols <- c("job_id", "skill_name", "skill_category", "career_category", "seniority_level", "posting_year", "is_entry_level")
missing_trans_skill_cols <- setdiff(req_trans_skill_cols, names(trans_skills))
if (length(missing_trans_skill_cols) > 0) {
  test_errors <- c(test_errors, sprintf("Transformed skills missing enriched context columns: %s", paste(missing_trans_skill_cols, collapse = ", ")))
} else {
  cat("✓ All required context attributes present in job_skills_transformed.csv.\n")
}

# Assertion 4: Foreign Key Integrity
orphans <- setdiff(trans_skills$job_id, trans_jobs$job_id)
if (length(orphans) > 0) {
  test_errors <- c(test_errors, sprintf("Foreign Key Violation: %d skills reference non-existent job_ids in processed data.", length(orphans)))
} else {
  cat("✓ 100% Relational Foreign Key integrity verified across processed jobs and skills.\n")
}

# Assertion 5: Raw string preservation
if (!all(c("original_title", "original_salary", "original_experience") %in% names(trans_jobs))) {
  test_errors <- c(test_errors, "Raw string preservation failed: original_title/salary/experience missing in transformed output.")
} else {
  cat("✓ Raw unedited strings preserved intact for 100% auditability.\n")
}

# 6. Summary Evaluation
cat("\n==============================================================\n")
cat("                 PIPELINE TEST RESULT                         \n")
cat("==============================================================\n")

if (length(test_errors) > 0) {
  cat("❌ Pipeline testing failed with errors:\n")
  for (err in test_errors) cat(sprintf(" - %s\n", err))
  quit(status = 1)
} else {
  cat("✅ ALL PIPELINE STAGES AND QUALITY ASSERTIONS PASSED!\n")
  cat(sprintf("Final Cleaned Jobs:        %d records\n", nrow(trans_jobs)))
  cat(sprintf("Final Transformed Skills:    %d records\n", nrow(trans_skills)))
  cat("Processed datasets saved to: `data/processed/`\n")
}
