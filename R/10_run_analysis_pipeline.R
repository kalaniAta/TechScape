# ==============================================================================
# TechScape: Master Analytical Pipeline Runner (R/10_run_analysis_pipeline.R)
# ==============================================================================
# PROVENANCE NOTICE:
# SYNTHETIC DEVELOPMENT DATA — NOT EMPIRICAL EVIDENCE
# This script executes all analytical modules sequentially on processed synthetic
# development datasets and verifies artifact generation across figures, tables,
# and findings.
# ==============================================================================

cat("\n==============================================================\n")
cat("       TECHSCAPE MASTER EXPLORATORY ANALYSIS PIPELINE         \n")
cat("==============================================================\n")
cat("Active Data: `data/processed/jobs_transformed.csv` (SYNTHETIC DEV DATA)\n\n")

# Run Analysis Modules
source("R/05_job_market_analysis.R")
source("R/06_skills_analysis.R")
source("R/07_salary_analysis.R")
source("R/08_experience_analysis.R")
source("R/09_cross_analysis.R")

# Verify Generated Output Artifacts
figures <- list.files("outputs/figures", pattern = "\\.png$", full.names = TRUE)
tables <- list.files("outputs/tables", pattern = "\\.csv$", full.names = TRUE)
findings <- list.files("outputs/findings", pattern = "\\.md$", full.names = TRUE)

cat("\n==============================================================\n")
cat("               ANALYTICAL ARTIFACT AUDIT                      \n")
cat("==============================================================\n")
cat(sprintf("Figures Generated:  %d (.png)\n", length(figures)))
for (f in figures) cat(sprintf("  - %s\n", basename(f)))

cat(sprintf("\nTables Generated:   %d (.csv)\n", length(tables)))
for (t in tables) cat(sprintf("  - %s\n", basename(t)))

cat(sprintf("\nFindings Generated: %d (.md)\n", length(findings)))
for (fd in findings) cat(sprintf("  - %s\n", basename(fd)))

cat("\n==============================================================\n")
cat("✅ MILESTONE 3 EXPLORATORY DATA ANALYSIS PIPELINE COMPLETE!\n")
cat("==============================================================\n")
