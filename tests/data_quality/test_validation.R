# ==============================================================================
# TechScape: Automated Data Quality & Validation Suite
# ==============================================================================
# Purpose: Executes schema verification, relational constraints, provenance checks,
# and quality profiling across synthetic testing and reference datasets.
# ==============================================================================

# Source pipeline modules
source("R/01_import.R")
source("R/02_validate.R")

cat("\n==============================================================\n")
cat("          TECHSCAPE DATA QUALITY & INTEGRITY TEST SUITE       \n")
cat("==============================================================\n")

# 1. Validate Active Synthetic Development Dataset (Primary Pipeline Asset)
synth_jobs_file <- "data/synthetic/jobs_synthetic_dev.csv"
synth_skills_file <- "data/synthetic/job_skills_synthetic_dev.csv"

cat("\n[TEST 1/2] Ingesting & Validating Synthetic Development Dataset...\n")
synth_data <- import_dataset_pair(synth_jobs_file, synth_skills_file)
synth_res <- validate_dataset(synth_data$jobs, synth_data$skills, dataset_name = "Synthetic Dev Dataset (Testing Asset)")

# 2. Validate Inferred Reference Dataset (Schema / Terminology Development Asset)
ref_jobs_file <- "data/reference/jobs_inferred_reference.csv"
ref_skills_file <- "data/reference/job_skills_inferred_reference.csv"

cat("\n[TEST 2/2] Ingesting & Validating Inferred Reference Dataset...\n")
ref_data <- import_dataset_pair(ref_jobs_file, ref_skills_file)
ref_res <- validate_dataset(ref_data$jobs, ref_data$skills, dataset_name = "Inferred Reference Dataset (Schema / Terminology Only)")

# 3. Check Real Sample Ingestion Status
cat("\n[STATUS] Real Data Directory (`data/real_sample/`): AWAITING_VERIFIED_REAL_DATA\n")

# 4. Overall Test Evaluation
cat("\n==============================================================\n")
cat("                       TEST SUMMARY                           \n")
cat("==============================================================\n")
cat(sprintf("Synthetic Dev Dataset Validation:   %s\n", ifelse(synth_res$is_valid, "PASSED", "FAILED")))
cat(sprintf("Inferred Reference Validation:      %s\n", ifelse(ref_res$is_valid, "PASSED", "FAILED")))
cat("Real-World Empirical Dataset:       PENDING INGESTION (Option B Testing Mode Active)\n")

all_passed <- synth_res$is_valid && ref_res$is_valid

if (!all_passed) {
  cat("\n❌ Automated validation encountered critical schema or integrity errors.\n")
  quit(status = 1)
} else {
  cat("\n✅ All active development and reference datasets successfully passed validation!\n")
}
