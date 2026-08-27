# ==============================================================================
# TechScape: Data Quality & Transformation Report Generator
# ==============================================================================
# Purpose: Compares dataset metrics before and after the cleaning and transformation
# stages, producing structured summary tables for Milestone 2 reporting.
#
# RULE: Clearly identifies dataset as SYNTHETIC DEVELOPMENT DATA.
# ==============================================================================

generate_quality_report <- function(
    raw_jobs_path = "data/synthetic/jobs_synthetic_dev.csv",
    raw_skills_path = "data/synthetic/job_skills_synthetic_dev.csv",
    processed_jobs_path = "data/processed/jobs_transformed.csv",
    processed_skills_path = "data/processed/job_skills_transformed.csv",
    output_report_path = "outputs/tables/data_quality_report.txt"
) {
  dir.create(dirname(output_report_path), recursive = TRUE, showWarnings = FALSE)
  
  jobs_raw <- read.csv(raw_jobs_path, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  skills_raw <- read.csv(raw_skills_path, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  
  jobs_proc <- read.csv(processed_jobs_path, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  skills_proc <- read.csv(processed_skills_path, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  
  lines <- character()
  
  add <- function(str = "") {
    lines <<- c(lines, str)
  }
  
  add("==============================================================================")
  add("               TECHSCAPE DATA QUALITY & TRANSFORMATION REPORT                 ")
  add("==============================================================================")
  add("DATASET CLASSIFICATION: SYNTHETIC DEVELOPMENT DATA (Testing Asset)")
  add(sprintf("Report Generated:       %s", Sys.time()))
  add("------------------------------------------------------------------------------")
  
  add("\n1. RECORD COUNTS & DEDUPLICATION SUMMARY")
  add(sprintf(" - Raw Jobs Count:                 %d", nrow(jobs_raw)))
  add(sprintf(" - Cleaned / Processed Jobs Count: %d", nrow(jobs_proc)))
  add(sprintf(" - Duplicates Removed:             %d", nrow(jobs_raw) - nrow(jobs_proc)))
  add(sprintf(" - Raw Skills Count:               %d", nrow(skills_raw)))
  add(sprintf(" - Cleaned / Processed Skills:     %d", nrow(skills_proc)))
  
  add("\n2. MISSINGNESS & DISCLOSURE PROFILE")
  add(sprintf(" - Raw Salary Undisclosed Rate:    %.1f%% (%d of %d)", 
              mean(is.na(jobs_raw$salary_min)) * 100, sum(is.na(jobs_raw$salary_min)), nrow(jobs_raw)))
  add(sprintf(" - Processed Salary Disclosed:     %.1f%% (%d of %d)", 
              mean(jobs_proc$salary_disclosed) * 100, sum(jobs_proc$salary_disclosed), nrow(jobs_proc)))
  add(sprintf(" - Experience Min Missingness:     %.1f%% (%d missing)", 
              mean(is.na(jobs_proc$experience_min)) * 100, sum(is.na(jobs_proc$experience_min))))
  add(sprintf(" - Work Mode Missingness:          %.1f%%", 
              mean(is.na(jobs_proc$work_mode) | jobs_proc$work_mode == "Unspecified") * 100))
  
  add("\n3. ENGINEERED VARIABLES SUMMARY")
  add(sprintf(" - Temporal Span:                  %d to %d (Span: %d years)", 
              min(jobs_proc$posting_year, na.rm=TRUE), max(jobs_proc$posting_year, na.rm=TRUE),
              max(jobs_proc$posting_year, na.rm=TRUE) - min(jobs_proc$posting_year, na.rm=TRUE) + 1))
  add(sprintf(" - Entry-Level Jobs Indicator:     %.1f%% (%d of %d postings)", 
              mean(jobs_proc$is_entry_level) * 100, sum(jobs_proc$is_entry_level), nrow(jobs_proc)))
  add(sprintf(" - Average Skills Per Job:         %.2f (Min: %d, Max: %d)", 
              mean(jobs_proc$skill_count), min(jobs_proc$skill_count), max(jobs_proc$skill_count)))
  
  add("\n4. CAREER CATEGORY DISTRIBUTION (DEVELOPMENT SYNTHETIC DATA)")
  cat_tab <- as.data.frame(table(jobs_proc$career_category), stringsAsFactors = FALSE)
  names(cat_tab) <- c("Career_Category", "Count")
  cat_tab$Percentage <- round((cat_tab$Count / nrow(jobs_proc)) * 100, 1)
  for (i in 1:nrow(cat_tab)) {
    add(sprintf(" - %-32s %3d (%4.1f%%)", cat_tab$Career_Category[i], cat_tab$Count[i], cat_tab$Percentage[i]))
  }
  
  add("\n5. SENIORITY LEVEL DISTRIBUTION")
  sen_tab <- as.data.frame(table(jobs_proc$seniority_level), stringsAsFactors = FALSE)
  names(sen_tab) <- c("Seniority", "Count")
  sen_tab$Percentage <- round((sen_tab$Count / nrow(jobs_proc)) * 100, 1)
  for (i in 1:nrow(sen_tab)) {
    add(sprintf(" - %-15s %3d (%4.1f%%)", sen_tab$Seniority[i], sen_tab$Count[i], sen_tab$Percentage[i]))
  }
  
  add("\n6. EXPERIENCE BAND DISTRIBUTION")
  exp_tab <- as.data.frame(table(jobs_proc$experience_band), stringsAsFactors = FALSE)
  names(exp_tab) <- c("Experience_Band", "Count")
  exp_tab$Percentage <- round((exp_tab$Count / nrow(jobs_proc)) * 100, 1)
  for (i in 1:nrow(exp_tab)) {
    add(sprintf(" - %-28s %3d (%4.1f%%)", exp_tab$Experience_Band[i], exp_tab$Count[i], exp_tab$Percentage[i]))
  }
  
  add("\n7. TOP SKILLS RECORDED (DEVELOPMENT SYNTHETIC DATA)")
  top_sk <- as.data.frame(head(sort(table(skills_proc$skill_name), decreasing = TRUE), 10))
  names(top_sk) <- c("Skill", "Count")
  top_sk$Penetration_Pct <- round((top_sk$Count / nrow(jobs_proc)) * 100, 1)
  for (i in 1:nrow(top_sk)) {
    add(sprintf(" - %-20s %3d occurrences (%4.1f%% penetration)", top_sk$Skill[i], top_sk$Count[i], top_sk$Penetration_Pct[i]))
  }
  
  add("\n==============================================================================")
  add("NOTICE: All metrics above represent SYNTHETIC DEVELOPMENT ASSETS.")
  add("They must NOT be cited or interpreted as empirical findings about Sri Lanka.")
  add("==============================================================================")
  
  report_text <- paste(lines, collapse = "\n")
  cat(report_text, "\n")
  writeLines(report_text, con = output_report_path)
  message(sprintf("\nSaved data quality report to: %s", output_report_path))
}

if (sys.nframe() == 0) {
  generate_quality_report()
}
