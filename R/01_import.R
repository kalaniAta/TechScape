# ==============================================================================
# TechScape: Data Import Module (R/01_import.R)
# ==============================================================================
# Purpose: Modular ingestion functions to read raw/synthetic/real job and skill
# CSV files into consistent R data structures with strict typing.
# ==============================================================================

#' Import Job Postings Dataset
#'
#' @param file_path Character. Path to the jobs CSV file.
#' @return A data.frame containing typed job records.
import_jobs <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(sprintf("Jobs file not found: %s", file_path))
  }
  
  col_classes <- c(
    "job_id" = "character",
    "source" = "character",
    "source_url" = "character",
    "collection_date" = "character",
    "source_job_id" = "character",
    "date_posted" = "character",
    "original_title" = "character",
    "job_title" = "character",
    "career_category" = "character",
    "seniority_level" = "character",
    "company" = "character",
    "location" = "character",
    "work_mode" = "character",
    "employment_type" = "character",
    "original_experience" = "character",
    "experience_min" = "numeric",
    "experience_max" = "numeric",
    "original_salary" = "character",
    "salary_min" = "numeric",
    "salary_max" = "numeric",
    "currency" = "character",
    "is_synthetic" = "logical"
  )
  
  df <- read.csv(
    file = file_path,
    colClasses = col_classes,
    na.strings = c("NA", "", "NULL", "null", "N/A"),
    stringsAsFactors = FALSE,
    encoding = "UTF-8"
  )
  
  message(sprintf("Imported %d job records from: %s", nrow(df), file_path))
  return(df)
}

#' Import Job Skills Dataset
#'
#' @param file_path Character. Path to the job_skills CSV file.
#' @return A data.frame containing typed skill records.
import_job_skills <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(sprintf("Skills file not found: %s", file_path))
  }
  
  col_classes <- c(
    "job_id" = "character",
    "skill_raw" = "character",
    "skill_name" = "character",
    "skill_category" = "character",
    "is_required" = "logical"
  )
  
  df <- read.csv(
    file = file_path,
    colClasses = col_classes,
    na.strings = c("NA", "", "NULL", "null", "N/A"),
    stringsAsFactors = FALSE,
    encoding = "UTF-8"
  )
  
  message(sprintf("Imported %d skill records from: %s", nrow(df), file_path))
  return(df)
}

#' Ingest Paired Jobs and Skills Datasets
#'
#' @param jobs_path Character. Path to jobs CSV.
#' @param skills_path Character. Path to skills CSV.
#' @return Named list with `jobs` and `skills` data frames.
import_dataset_pair <- function(jobs_path, skills_path) {
  jobs <- import_jobs(jobs_path)
  skills <- import_job_skills(skills_path)
  
  return(list(
    jobs = jobs,
    skills = skills
  ))
}
