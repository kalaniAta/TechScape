# ==============================================================================
# TechScape: Data Validation Module (R/02_validate.R)
# ==============================================================================
# Purpose: Comprehensive schema, provenance, relational integrity, and data
# quality validation engine for TechScape datasets.
# ==============================================================================

REQUIRED_JOBS_COLUMNS <- c(
  "job_id", "source", "source_url", "collection_date", "source_job_id",
  "date_posted", "original_title", "job_title", "career_category",
  "seniority_level", "company", "location", "work_mode", "employment_type",
  "original_experience", "experience_min", "experience_max",
  "original_salary", "salary_min", "salary_max", "currency", "is_synthetic"
)

REQUIRED_SKILLS_COLUMNS <- c(
  "job_id", "skill_raw", "skill_name", "skill_category", "is_required"
)

VALID_CAREER_CATEGORIES <- c(
  "Software Engineering",
  "QA & Test Automation",
  "Cloud & DevOps",
  "Data & AI / ML",
  "Cyber Security",
  "UI/UX & Product Design",
  "IT Systems & Infrastructure",
  "Management & Business Analysis"
)

VALID_SKILL_CATEGORIES <- c(
  "Programming Language",
  "Framework/Library",
  "Database",
  "Cloud/DevOps",
  "Tool/Methodology",
  "Domain/Other"
)

#' Validate Structure and Quality of TechScape Dataset Pair
#'
#' @param jobs_df data.frame of job postings
#' @param skills_df data.frame of job skills
#' @param dataset_name Character name of dataset for reporting
#' @return List containing boolean status `is_valid`, `errors`, `warnings`, and `summary`
validate_dataset <- function(jobs_df, skills_df, dataset_name = "Dataset") {
  errors <- character()
  warnings <- character()
  
  message(sprintf("\n======================================================="))
  message(sprintf("Running Validation on: %s", dataset_name))
  message(sprintf("======================================================="))
  
  # --------------------------------------------------------------------------
  # 1. Column Presence Checks
  # --------------------------------------------------------------------------
  missing_job_cols <- setdiff(REQUIRED_JOBS_COLUMNS, names(jobs_df))
  if (length(missing_job_cols) > 0) {
    errors <- c(errors, sprintf("Jobs table missing required columns: %s", paste(missing_job_cols, collapse = ", ")))
  }
  
  missing_skill_cols <- setdiff(REQUIRED_SKILLS_COLUMNS, names(skills_df))
  if (length(missing_skill_cols) > 0) {
    errors <- c(errors, sprintf("Skills table missing required columns: %s", paste(missing_skill_cols, collapse = ", ")))
  }
  
  if (length(errors) > 0) {
    message("❌ Schema check failed. Halting further validation.")
    return(list(is_valid = FALSE, errors = errors, warnings = warnings, summary = NULL))
  }
  
  # --------------------------------------------------------------------------
  # 2. Record Counts & Provenance Flag
  # --------------------------------------------------------------------------
  n_jobs <- nrow(jobs_df)
  n_skills <- nrow(skills_df)
  synthetic_flags <- unique(jobs_df$is_synthetic)
  
  message(sprintf("Total Job Records: %d", n_jobs))
  message(sprintf("Total Skill Records: %d", n_skills))
  message(sprintf("Dataset Classification: %s", 
                  ifelse(all(jobs_df$is_synthetic), "SYNTHETIC TESTING DATASET", "REAL EMPIRICAL DATASET")))
  
  # --------------------------------------------------------------------------
  # 3. Provenance Integrity for Real Data
  # --------------------------------------------------------------------------
  if (any(!jobs_df$is_synthetic)) {
    real_jobs <- jobs_df[!jobs_df$is_synthetic, ]
    missing_source <- sum(is.na(real_jobs$source) | real_jobs$source == "")
    missing_col_date <- sum(is.na(real_jobs$collection_date) | real_jobs$collection_date == "")
    missing_orig_title <- sum(is.na(real_jobs$original_title) | real_jobs$original_title == "")
    
    if (missing_source > 0) {
      errors <- c(errors, sprintf("Real dataset has %d records missing 'source' provenance.", missing_source))
    }
    if (missing_col_date > 0) {
      errors <- c(errors, sprintf("Real dataset has %d records missing 'collection_date'.", missing_col_date))
    }
    if (missing_orig_title > 0) {
      errors <- c(errors, sprintf("Real dataset has %d records missing unedited 'original_title'.", missing_orig_title))
    }
  }
  
  # --------------------------------------------------------------------------
  # 4. Primary Key & Duplicate Analysis
  # --------------------------------------------------------------------------
  dup_job_ids <- sum(duplicated(jobs_df$job_id))
  if (dup_job_ids > 0) {
    errors <- c(errors, sprintf("Primary Key Violation: Found %d duplicate 'job_id' values.", dup_job_ids))
  }
  
  # Check for identical duplicate postings (by company, title, and date)
  dup_postings <- sum(duplicated(jobs_df[, c("company", "original_title", "date_posted")]))
  if (dup_postings > 0) {
    warnings <- c(warnings, sprintf("Data Quality Notice: Detected %d duplicate job postings across company/title/date.", dup_postings))
  }
  
  # --------------------------------------------------------------------------
  # 5. Foreign Key & Relational Integrity
  # --------------------------------------------------------------------------
  orphaned_skills <- setdiff(skills_df$job_id, jobs_df$job_id)
  if (length(orphaned_skills) > 0) {
    errors <- c(errors, sprintf("Foreign Key Violation: %d skills reference non-existent 'job_id' values.", length(orphaned_skills)))
  }
  
  jobs_without_skills <- setdiff(jobs_df$job_id, skills_df$job_id)
  if (length(jobs_without_skills) > 0) {
    warnings <- c(warnings, sprintf("Notice: %d jobs have 0 associated skills in skills table.", length(jobs_without_skills)))
  }
  
  # --------------------------------------------------------------------------
  # 6. Logical Bounds on Numeric Variables
  # --------------------------------------------------------------------------
  invalid_exp_min <- sum(!is.na(jobs_df$experience_min) & jobs_df$experience_min < 0)
  if (invalid_exp_min > 0) {
    errors <- c(errors, sprintf("%d records have negative 'experience_min'.", invalid_exp_min))
  }
  
  inverted_exp <- sum(!is.na(jobs_df$experience_min) & !is.na(jobs_df$experience_max) & 
                        jobs_df$experience_min > jobs_df$experience_max)
  if (inverted_exp > 0) {
    errors <- c(errors, sprintf("%d records have 'experience_min' greater than 'experience_max'.", inverted_exp))
  }
  
  invalid_sal_min <- sum(!is.na(jobs_df$salary_min) & jobs_df$salary_min <= 0)
  if (invalid_sal_min > 0) {
    errors <- c(errors, sprintf("%d records have non-positive 'salary_min'.", invalid_sal_min))
  }
  
  inverted_sal <- sum(!is.na(jobs_df$salary_min) & !is.na(jobs_df$salary_max) & 
                        jobs_df$salary_min > jobs_df$salary_max)
  if (inverted_sal > 0) {
    errors <- c(errors, sprintf("%d records have 'salary_min' greater than 'salary_max'.", inverted_sal))
  }
  
  # --------------------------------------------------------------------------
  # 7. Category Conformance Checks
  # --------------------------------------------------------------------------
  unknown_careers <- setdiff(na.omit(jobs_df$career_category), VALID_CAREER_CATEGORIES)
  if (length(unknown_careers) > 0) {
    warnings <- c(warnings, sprintf("Non-standard career categories found: %s", paste(unknown_careers, collapse = ", ")))
  }
  
  unknown_skill_cats <- setdiff(na.omit(skills_df$skill_category), VALID_SKILL_CATEGORIES)
  if (length(unknown_skill_cats) > 0) {
    warnings <- c(warnings, sprintf("Non-standard skill categories found: %s", paste(unknown_skill_cats, collapse = ", ")))
  }
  
  # --------------------------------------------------------------------------
  # 8. Missingness Profile Summary
  # --------------------------------------------------------------------------
  pct_missing_salary <- mean(is.na(jobs_df$salary_min)) * 100
  pct_missing_exp <- mean(is.na(jobs_df$experience_min)) * 100
  pct_missing_workmode <- mean(is.na(jobs_df$work_mode)) * 100
  
  summary_metrics <- list(
    total_jobs = n_jobs,
    total_skills = n_skills,
    salary_disclosure_rate_pct = round(100 - pct_missing_salary, 2),
    salary_missing_pct = round(pct_missing_salary, 2),
    experience_missing_pct = round(pct_missing_exp, 2),
    work_mode_missing_pct = round(pct_missing_workmode, 2),
    avg_skills_per_job = round(n_skills / max(1, n_jobs), 2)
  )
  
  # --------------------------------------------------------------------------
  # 9. Output Reporting
  # --------------------------------------------------------------------------
  is_valid <- length(errors) == 0
  
  message("\n--- Validation Summary ---")
  message(sprintf("Status: %s", ifelse(is_valid, "✅ PASSED", "❌ FAILED")))
  message(sprintf("Salary Disclosure Rate: %.1f%% (Missing: %.1f%%)", 
                  summary_metrics$salary_disclosure_rate_pct, summary_metrics$salary_missing_pct))
  message(sprintf("Experience Field Missing Rate: %.1f%%", summary_metrics$experience_missing_pct))
  message(sprintf("Average Skills Recorded Per Job: %.1f", summary_metrics$avg_skills_per_job))
  
  if (length(warnings) > 0) {
    message("\n⚠️ Warnings / Quality Notices:")
    for (w in warnings) message(sprintf(" - %s", w))
  }
  
  if (length(errors) > 0) {
    message("\n❌ Validation Errors:")
    for (e in errors) message(sprintf(" - %s", e))
  }
  
  return(list(
    is_valid = is_valid,
    errors = errors,
    warnings = warnings,
    summary = summary_metrics
  ))
}
