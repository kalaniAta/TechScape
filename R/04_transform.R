# ==============================================================================
# TechScape: Feature Engineering & Data Transformation (R/04_transform.R)
# ==============================================================================
# Purpose: Ingests cleaned datasets, derives analytical features (temporal
# partitioning, experience banding, salary banding, entry-level accessibility flags,
# and aggregated skill metrics), and generates analysis-ready transformed tables.
#
# RULE: Traceability to raw records is strictly maintained via `job_id`.
# DATASET SCOPE: Strictly applied to development/testing synthetic datasets.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Feature Engineering Helper Functions
# ------------------------------------------------------------------------------

#' Assign Experience Band
assign_experience_band <- function(exp_min) {
  if (is.na(exp_min)) return("Unspecified")
  if (exp_min <= 1) return("0-1 Years (Entry/Junior)")
  if (exp_min <= 4) return("2-4 Years (Mid-Level)")
  if (exp_min <= 7) return("5-7 Years (Senior)")
  return("8+ Years (Lead/Principal)")
}

#' Assign LKR Salary Band
assign_lkr_salary_band <- function(salary_midpoint, currency) {
  if (is.na(currency) || currency != "LKR" || is.na(salary_midpoint)) {
    return("Undisclosed / Non-LKR")
  }
  if (salary_midpoint < 150000) return("< 150k LKR")
  if (salary_midpoint < 300000) return("150k - 300k LKR")
  if (salary_midpoint < 500000) return("300k - 500k LKR")
  if (salary_midpoint < 750000) return("500k - 750k LKR")
  return("750k+ LKR")
}

#' Assign USD Salary Band
assign_usd_salary_band <- function(salary_midpoint, currency) {
  if (is.na(currency) || currency != "USD" || is.na(salary_midpoint)) {
    return("Undisclosed / Non-USD")
  }
  if (salary_midpoint < 1000) return("< $1,000 USD")
  if (salary_midpoint < 1800) return("$1,000 - $1,800 USD")
  if (salary_midpoint < 2500) return("$1,800 - $2,500 USD")
  return("$2,500+ USD")
}

# ------------------------------------------------------------------------------
# 2. Main Transformation Function
# ------------------------------------------------------------------------------

#' Run Transformation and Feature Engineering Pipeline
transform_pipeline_datasets <- function(
    cleaned_jobs_path = "data/processed/jobs_cleaned.csv",
    cleaned_skills_path = "data/processed/job_skills_cleaned.csv",
    transformed_jobs_path = "data/processed/jobs_transformed.csv",
    transformed_skills_path = "data/processed/job_skills_transformed.csv"
) {
  message("\n=======================================================")
  message("        TECHSCAPE DATA TRANSFORMATION PIPELINE         ")
  message("=======================================================")
  
  if (!file.exists(cleaned_jobs_path) || !file.exists(cleaned_skills_path)) {
    stop("Cleaned datasets missing. Please run R/03_clean.R first.")
  }
  
  jobs <- read.csv(cleaned_jobs_path, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  skills <- read.csv(cleaned_skills_path, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  
  message(sprintf("Loaded %d cleaned jobs and %d cleaned skills...", nrow(jobs), nrow(skills)))
  
  # --------------------------------------------------------------------------
  # 1. Temporal Feature Extraction
  # --------------------------------------------------------------------------
  dates <- as.Date(jobs$date_posted)
  jobs$posting_year <- as.integer(format(dates, "%Y"))
  jobs$posting_month <- as.integer(format(dates, "%m"))
  
  # Derive Quarter
  m <- jobs$posting_month
  quarters <- ifelse(m <= 3, "Q1", ifelse(m <= 6, "Q2", ifelse(m <= 9, "Q3", "Q4")))
  jobs$posting_quarter <- quarters
  jobs$posting_year_quarter <- sprintf("%d-%s", jobs$posting_year, jobs$posting_quarter)
  jobs$posting_year_month <- format(dates, "%Y-%m")
  
  # --------------------------------------------------------------------------
  # 2. Entry-Level Accessibility Indicator & Experience Banding
  # --------------------------------------------------------------------------
  jobs$is_entry_level <- (!is.na(jobs$experience_min) & jobs$experience_min <= 1) |
                         (jobs$seniority_level %in% c("Intern", "Junior")) |
                         (jobs$employment_type == "Internship")
  
  jobs$experience_band <- sapply(jobs$experience_min, assign_experience_band)
  
  # --------------------------------------------------------------------------
  # 3. Salary Feature Engineering & Midpoint Derivation
  # --------------------------------------------------------------------------
  jobs$salary_disclosed <- !is.na(jobs$salary_min)
  
  # Derive midpoint
  sal_mid <- ifelse(
    !is.na(jobs$salary_min) & !is.na(jobs$salary_max),
    (jobs$salary_min + jobs$salary_max) / 2,
    ifelse(!is.na(jobs$salary_min), jobs$salary_min, NA_real_)
  )
  jobs$salary_midpoint <- sal_mid
  
  # Salary bands
  jobs$salary_band_lkr <- mapply(assign_lkr_salary_band, jobs$salary_midpoint, jobs$currency)
  jobs$salary_band_usd <- mapply(assign_usd_salary_band, jobs$salary_midpoint, jobs$currency)
  
  # --------------------------------------------------------------------------
  # 4. Aggregated Skill Metrics Per Job
  # --------------------------------------------------------------------------
  skill_counts <- as.data.frame(table(skills$job_id), stringsAsFactors = FALSE)
  names(skill_counts) <- c("job_id", "skill_count")
  
  # Aggregate concatenated skills
  skill_aggr <- aggregate(skill_name ~ job_id, data = skills, FUN = function(x) paste(unique(x), collapse = "; "))
  names(skill_aggr) <- c("job_id", "skill_names_concat")
  
  # Skill category boolean presence
  prog_jobs <- unique(skills$job_id[skills$skill_category == "Programming Language"])
  cloud_jobs <- unique(skills$job_id[skills$skill_category == "Cloud/DevOps"])
  framework_jobs <- unique(skills$job_id[skills$skill_category == "Framework/Library"])
  db_jobs <- unique(skills$job_id[skills$skill_category == "Database"])
  
  jobs$skill_count <- ifelse(jobs$job_id %in% skill_counts$job_id, 
                             skill_counts$skill_count[match(jobs$job_id, skill_counts$job_id)], 0)
  jobs$skill_names_concat <- ifelse(jobs$job_id %in% skill_aggr$job_id, 
                                   skill_aggr$skill_names_concat[match(jobs$job_id, skill_aggr$job_id)], "")
  
  jobs$has_prog_lang <- jobs$job_id %in% prog_jobs
  jobs$has_cloud_devops <- jobs$job_id %in% cloud_jobs
  jobs$has_framework <- jobs$job_id %in% framework_jobs
  jobs$has_database <- jobs$job_id %in% db_jobs
  
  # --------------------------------------------------------------------------
  # 5. Enrich Relational Skill Dataset with Job Context
  # --------------------------------------------------------------------------
  job_lookup <- jobs[, c("job_id", "career_category", "seniority_level", "posting_year", "is_entry_level", "work_mode")]
  skills_transformed <- merge(skills, job_lookup, by = "job_id", all.x = TRUE)
  
  # --------------------------------------------------------------------------
  # 6. Save Transformed Datasets
  # --------------------------------------------------------------------------
  write.csv(jobs, file = transformed_jobs_path, row.names = FALSE, na = "NA")
  write.csv(skills_transformed, file = transformed_skills_path, row.names = FALSE, na = "NA")
  
  message(sprintf("\n✅ Transformation complete!"))
  message(sprintf("Transformed jobs written to:   %s (%d rows, %d columns)", 
                  transformed_jobs_path, nrow(jobs), ncol(jobs)))
  message(sprintf("Transformed skills written to: %s (%d rows, %d columns)", 
                  transformed_skills_path, nrow(skills_transformed), ncol(skills_transformed)))
  
  # Summary diagnostics
  message(sprintf("Temporal range: %d to %d", min(jobs$posting_year, na.rm=TRUE), max(jobs$posting_year, na.rm=TRUE)))
  message(sprintf("Entry-level job ratio: %.1f%% (%d of %d jobs)", 
                  mean(jobs$is_entry_level) * 100, sum(jobs$is_entry_level), nrow(jobs)))
  message(sprintf("Overall Salary disclosure: %.1f%% (%d disclosed)", 
                  mean(jobs$salary_disclosed) * 100, sum(jobs$salary_disclosed)))
  
  invisible(list(jobs = jobs, skills = skills_transformed))
}

if (sys.nframe() == 0) {
  transform_pipeline_datasets()
}
