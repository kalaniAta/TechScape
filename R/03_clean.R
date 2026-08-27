# ==============================================================================
# TechScape: Data Cleaning Module (R/03_clean.R)
# ==============================================================================
# Purpose: Ingests raw/synthetic development datasets, performs robust missingness
# handling, salary and experience normalization, job title standardization,
# canonical skill mapping, deduplication, and writes cleaned CSV outputs.
#
# RULE: Preserves raw unmodified fields intact for 100% auditability.
# DATASET SCOPE: Strictly applied to development/testing synthetic datasets.
# ==============================================================================

source("R/01_import.R")

# ------------------------------------------------------------------------------
# 1. Canonical Taxonomies & Mapping Dictionaries
# ------------------------------------------------------------------------------

CAREER_CATEGORY_LOOKUP <- list(
  "Software Engineering" = c("software", "full stack", "full-stack", "frontend", "front end", 
                             "backend", "back end", "mobile", "ios", "android", "flutter", 
                             "react native", "developer", "se", "sse", "architect", "golang", "c++", ".net", "java"),
  "QA & Test Automation" = c("qa", "quality assurance", "test", "tester", "sdet", "automation", 
                             "playwright", "selenium", "cypress", "jmeter", "manual testing"),
  "Cloud & DevOps" = c("devops", "cloud", "sre", "site reliability", "platform", "infrastructure", 
                       "sysops", "kubernetes", "terraform", "aws", "azure", "gcp"),
  "Data & AI / ML" = c("data", "scientist", "machine learning", "ml", "ai", "bi", "analytics", 
                       "deep learning", "pyspark", "power bi", "nlp", "llm", "computer vision"),
  "Cyber Security" = c("security", "cyber", "soc", "siem", "penetration", "vapt", "infosec", 
                       "ethical hacker", "grc", "iso 27001"),
  "UI/UX & Product Design" = c("ui", "ux", "ui/ux", "product designer", "interaction", "visual designer", 
                               "figma", "prototyping", "design"),
  "IT Systems & Infrastructure" = c("system admin", "systems", "network", "noc", "desktop support", 
                                   "it support", "helpdesk", "active directory", "cisco", "hardware"),
  "Management & Business Analysis" = c("business analyst", "ba", "project manager", "scrum master", 
                                       "product owner", "agile", "delivery lead", "engineering manager")
)

SKILL_CANONICAL_LOOKUP <- list(
  # Programming Languages
  "python" = list(name = "Python", category = "Programming Language"),
  "python 3" = list(name = "Python", category = "Programming Language"),
  "python3" = list(name = "Python", category = "Programming Language"),
  "java" = list(name = "Java", category = "Programming Language"),
  "java 17" = list(name = "Java", category = "Programming Language"),
  "core java" = list(name = "Java", category = "Programming Language"),
  "javascript" = list(name = "JavaScript", category = "Programming Language"),
  "typescript" = list(name = "TypeScript", category = "Programming Language"),
  "ts" = list(name = "TypeScript", category = "Programming Language"),
  "c#" = list(name = "C#", category = "Programming Language"),
  "c#.net" = list(name = "C#", category = "Programming Language"),
  "c++" = list(name = "C++", category = "Programming Language"),
  "c++17/20" = list(name = "C++", category = "Programming Language"),
  "golang" = list(name = "Go", category = "Programming Language"),
  "go" = list(name = "Go", category = "Programming Language"),
  "dart" = list(name = "Dart", category = "Programming Language"),
  "php" = list(name = "PHP", category = "Programming Language"),
  "ruby" = list(name = "Ruby", category = "Programming Language"),
  "scala" = list(name = "Scala", category = "Programming Language"),
  "dax" = list(name = "DAX", category = "Programming Language"),
  "html5/css3" = list(name = "HTML/CSS", category = "Programming Language"),
  
  # Frameworks & Libraries
  "react" = list(name = "React", category = "Framework/Library"),
  "react.js" = list(name = "React", category = "Framework/Library"),
  "reactjs" = list(name = "React", category = "Framework/Library"),
  "react native" = list(name = "React Native", category = "Framework/Library"),
  "next.js" = list(name = "Next.js", category = "Framework/Library"),
  "node.js" = list(name = "Node.js", category = "Framework/Library"),
  "nodejs" = list(name = "Node.js", category = "Framework/Library"),
  "node" = list(name = "Node.js", category = "Framework/Library"),
  "spring boot" = list(name = "Spring Boot", category = "Framework/Library"),
  "springboot" = list(name = "Spring Boot", category = "Framework/Library"),
  "spring-boot" = list(name = "Spring Boot", category = "Framework/Library"),
  ".net" = list(name = ".NET", category = "Framework/Library"),
  ".net core" = list(name = ".NET", category = "Framework/Library"),
  ".net 8" = list(name = ".NET", category = "Framework/Library"),
  "dot net" = list(name = ".NET", category = "Framework/Library"),
  "angular" = list(name = "Angular", category = "Framework/Library"),
  "angular 14+" = list(name = "Angular", category = "Framework/Library"),
  "vue" = list(name = "Vue", category = "Framework/Library"),
  "vue.js" = list(name = "Vue", category = "Framework/Library"),
  "django" = list(name = "Django", category = "Framework/Library"),
  "laravel" = list(name = "Laravel", category = "Framework/Library"),
  "laravel 10" = list(name = "Laravel", category = "Framework/Library"),
  "ruby on rails" = list(name = "Rails", category = "Framework/Library"),
  "flutter" = list(name = "Flutter", category = "Framework/Library"),
  "pytorch" = list(name = "PyTorch", category = "Framework/Library"),
  "tensorflow" = list(name = "TensorFlow", category = "Framework/Library"),
  "pyspark" = list(name = "PySpark", category = "Framework/Library"),
  "pandas" = list(name = "Pandas", category = "Framework/Library"),
  "scikit-learn" = list(name = "Scikit-Learn", category = "Framework/Library"),
  "opencv" = list(name = "OpenCV", category = "Framework/Library"),
  "langchain" = list(name = "LangChain", category = "Framework/Library"),
  "llm / langchain" = list(name = "LangChain", category = "Framework/Library"),
  "redux" = list(name = "Redux", category = "Framework/Library"),
  "tailwind css" = list(name = "Tailwind CSS", category = "Framework/Library"),
  "tailwindcss" = list(name = "Tailwind CSS", category = "Framework/Library"),
  "grpc" = list(name = "gRPC", category = "Framework/Library"),
  "testng" = list(name = "TestNG", category = "Framework/Library"),
  "restassured" = list(name = "RestAssured", category = "Framework/Library"),
  "spark" = list(name = "Spark", category = "Framework/Library"),
  "apache spark" = list(name = "Spark", category = "Framework/Library"),
  
  # Databases
  "postgresql" = list(name = "PostgreSQL", category = "Database"),
  "postgres" = list(name = "PostgreSQL", category = "Database"),
  "mysql" = list(name = "MySQL", category = "Database"),
  "sql" = list(name = "SQL", category = "Database"),
  "sql server" = list(name = "Microsoft SQL Server", category = "Database"),
  "ms sql server" = list(name = "Microsoft SQL Server", category = "Database"),
  "sql queries" = list(name = "SQL", category = "Database"),
  "advanced sql" = list(name = "SQL", category = "Database"),
  "pinecone / chromadb" = list(name = "Vector Database", category = "Database"),
  "vector database" = list(name = "Vector Database", category = "Database"),
  
  # Cloud / DevOps
  "aws" = list(name = "AWS", category = "Cloud/DevOps"),
  "aws cloud" = list(name = "AWS", category = "Cloud/DevOps"),
  "amazon web services" = list(name = "AWS", category = "Cloud/DevOps"),
  "azure" = list(name = "Azure", category = "Cloud/DevOps"),
  "microsoft azure" = list(name = "Azure", category = "Cloud/DevOps"),
  "gcp" = list(name = "GCP", category = "Cloud/DevOps"),
  "google cloud platform (gcp)" = list(name = "GCP", category = "Cloud/DevOps"),
  "docker" = list(name = "Docker", category = "Cloud/DevOps"),
  "kubernetes" = list(name = "Kubernetes", category = "Cloud/DevOps"),
  "k8s" = list(name = "Kubernetes", category = "Cloud/DevOps"),
  "kubernetes (aks)" = list(name = "Kubernetes", category = "Cloud/DevOps"),
  "kubernetes (gke)" = list(name = "Kubernetes", category = "Cloud/DevOps"),
  "terraform" = list(name = "Terraform", category = "Cloud/DevOps"),
  "iac" = list(name = "Terraform", category = "Cloud/DevOps"),
  "devsecops" = list(name = "DevSecOps", category = "Cloud/DevOps"),
  
  # Tools & Methodologies
  "selenium" = list(name = "Selenium", category = "Tool/Methodology"),
  "selenium webdriver" = list(name = "Selenium", category = "Tool/Methodology"),
  "cypress" = list(name = "Cypress", category = "Tool/Methodology"),
  "cypress.io" = list(name = "Cypress", category = "Tool/Methodology"),
  "playwright" = list(name = "Playwright", category = "Tool/Methodology"),
  "postman" = list(name = "Postman", category = "Tool/Methodology"),
  "jmeter" = list(name = "JMeter", category = "Tool/Methodology"),
  "k6" = list(name = "K6", category = "Tool/Methodology"),
  "ci/cd" = list(name = "CI/CD", category = "Tool/Methodology"),
  "ci-cd pipelines" = list(name = "CI/CD", category = "Tool/Methodology"),
  "gitlab ci" = list(name = "CI/CD", category = "Tool/Methodology"),
  "jira" = list(name = "JIRA", category = "Tool/Methodology"),
  "jira / confluence" = list(name = "JIRA", category = "Tool/Methodology"),
  "git" = list(name = "Git", category = "Tool/Methodology"),
  "figma" = list(name = "Figma", category = "Tool/Methodology"),
  "power bi" = list(name = "Power BI", category = "Tool/Methodology"),
  "powerbi" = list(name = "Power BI", category = "Tool/Methodology"),
  "linux" = list(name = "Linux", category = "Tool/Methodology"),
  "linux administration" = list(name = "Linux", category = "Tool/Methodology"),
  "ubuntu/rhel" = list(name = "Linux", category = "Tool/Methodology"),
  "windows server" = list(name = "Windows Server", category = "Tool/Methodology"),
  "active directory" = list(name = "Active Directory", category = "Tool/Methodology"),
  "cisco" = list(name = "Cisco", category = "Tool/Methodology"),
  "cisco routing" = list(name = "Cisco", category = "Tool/Methodology"),
  "microservices" = list(name = "Microservices", category = "Tool/Methodology"),
  "rest api" = list(name = "REST API", category = "Tool/Methodology"),
  "rest apis" = list(name = "REST API", category = "Tool/Methodology"),
  "restful api" = list(name = "REST API", category = "Tool/Methodology"),
  "agile" = list(name = "Agile", category = "Tool/Methodology"),
  "scrum" = list(name = "Agile", category = "Tool/Methodology"),
  "agile/scrum" = list(name = "Agile", category = "Tool/Methodology"),
  "sonarqube" = list(name = "SonarQube", category = "Tool/Methodology"),
  "siem" = list(name = "SIEM", category = "Tool/Methodology"),
  "splunk" = list(name = "Splunk", category = "Tool/Methodology"),
  "manual testing" = list(name = "Manual Testing", category = "Tool/Methodology"),
  "manual qa" = list(name = "Manual Testing", category = "Tool/Methodology")
)

# ------------------------------------------------------------------------------
# 2. Cleaning Functions
# ------------------------------------------------------------------------------

#' Clean and Standardize Job Title String
clean_title_string <- function(title_raw) {
  if (is.na(title_raw) || title_raw == "") return("Unspecified Role")
  
  t_clean <- trimws(title_raw)
  # Standardize common abbreviations
  t_clean <- gsub("\\bSE\\b", "Software Engineer", t_clean, ignore.case = FALSE)
  t_clean <- gsub("\\bSSE\\b", "Senior Software Engineer", t_clean, ignore.case = FALSE)
  t_clean <- gsub("\\bSr\\.\\s*", "Senior ", t_clean, ignore.case = TRUE)
  t_clean <- gsub("\\bDev\\b", "Developer", t_clean, ignore.case = TRUE)
  t_clean <- gsub("\\bEng\\b", "Engineer", t_clean, ignore.case = TRUE)
  t_clean <- gsub("\\bQA / Tester\\b", "QA Engineer", t_clean, ignore.case = TRUE)
  t_clean <- gsub("\\s+", " ", t_clean)
  
  return(trimws(t_clean))
}

#' Normalize Canonical Skill
normalize_skill <- function(raw_skill) {
  if (is.na(raw_skill) || raw_skill == "") {
    return(list(name = "Unspecified", category = "Domain/Other"))
  }
  
  key <- tolower(trimws(raw_skill))
  if (key %in% names(SKILL_CANONICAL_LOOKUP)) {
    return(SKILL_CANONICAL_LOOKUP[[key]])
  }
  
  # Default fallback: title case raw name
  title_cased <- tools::toTitleCase(raw_skill)
  return(list(name = title_cased, category = "Domain/Other"))
}

#' Standardize Seniority Level
derive_seniority_level <- function(title, explicit_seniority = NA) {
  if (!is.na(explicit_seniority) && explicit_seniority %in% c("Intern", "Junior", "Mid", "Senior", "Lead", "Management")) {
    return(explicit_seniority)
  }
  
  t_lower <- tolower(title)
  if (grepl("intern|trainee|undergraduate", t_lower)) return("Intern")
  if (grepl("associate|junior|entry|grad", t_lower)) return("Junior")
  if (grepl("lead|principal|head|director|manager|architect", t_lower)) return("Lead")
  if (grepl("senior|sr", t_lower)) return("Senior")
  if (grepl("mid|intermediate", t_lower)) return("Mid")
  
  return("Mid") # Default standard baseline
}

#' Deduplicate Job Postings while Logging Duplicate Records
deduplicate_jobs <- function(jobs_df) {
  initial_count <- nrow(jobs_df)
  # Check duplicates based on company, clean title, date_posted, location
  dup_logical <- duplicated(jobs_df[, c("company", "original_title", "date_posted")])
  dup_count <- sum(dup_logical)
  
  if (dup_count > 0) {
    dup_ids <- jobs_df$job_id[dup_logical]
    message(sprintf("Deduplication: Removed %d duplicate job postings: %s", 
                    dup_count, paste(head(dup_ids, 5), collapse = ", ")))
    cleaned_jobs <- jobs_df[!dup_logical, ]
  } else {
    message("Deduplication: 0 duplicate records detected.")
    cleaned_jobs <- jobs_df
  }
  
  return(list(
    jobs = cleaned_jobs,
    removed_count = dup_count,
    removed_ids = if (dup_count > 0) jobs_df$job_id[dup_logical] else character()
  ))
}

# ------------------------------------------------------------------------------
# 3. Main Data Cleaning Pipeline Runner
# ------------------------------------------------------------------------------

#' Run Complete Cleaning Pipeline on Synthetic Development Dataset
clean_pipeline_datasets <- function(
    jobs_input_path = "data/synthetic/jobs_synthetic_dev.csv",
    skills_input_path = "data/synthetic/job_skills_synthetic_dev.csv",
    jobs_output_path = "data/processed/jobs_cleaned.csv",
    skills_output_path = "data/processed/job_skills_cleaned.csv"
) {
  message("\n=======================================================")
  message("           TECHSCAPE DATA CLEANING PIPELINE            ")
  message("=======================================================")
  
  dir.create(dirname(jobs_output_path), recursive = TRUE, showWarnings = FALSE)
  
  # 1. Import
  raw_data <- import_dataset_pair(jobs_input_path, skills_input_path)
  jobs <- raw_data$jobs
  skills <- raw_data$skills
  
  n_jobs_raw <- nrow(jobs)
  n_skills_raw <- nrow(skills)
  
  # 2. Clean Jobs Table
  message("Cleaning jobs dataset...")
  
  # Ensure date format
  jobs$date_posted <- as.character(as.Date(jobs$date_posted, format = "%Y-%m-%d"))
  jobs$collection_date <- as.character(as.Date(jobs$collection_date, format = "%Y-%m-%d"))
  
  # Clean job title
  jobs$job_title <- sapply(jobs$original_title, clean_title_string)
  
  # Standardize seniority level
  jobs$seniority_level <- mapply(derive_seniority_level, jobs$job_title, jobs$seniority_level)
  
  # Normalize work mode and employment type
  jobs$work_mode <- ifelse(is.na(jobs$work_mode) | jobs$work_mode == "", "Unspecified", trimws(jobs$work_mode))
  jobs$employment_type <- ifelse(is.na(jobs$employment_type) | jobs$employment_type == "", "Full-time", trimws(jobs$employment_type))
  
  # Handle salary numbers and preserve NA
  jobs$salary_min <- as.numeric(jobs$salary_min)
  jobs$salary_max <- as.numeric(jobs$salary_max)
  # Fix any cases where salary_max < salary_min
  sal_inverted <- !is.na(jobs$salary_min) & !is.na(jobs$salary_max) & jobs$salary_min > jobs$salary_max
  if (any(sal_inverted)) {
    tmp <- jobs$salary_min[sal_inverted]
    jobs$salary_min[sal_inverted] <- jobs$salary_max[sal_inverted]
    jobs$salary_max[sal_inverted] <- tmp
  }
  
  # Handle experience numbers
  jobs$experience_min <- as.numeric(jobs$experience_min)
  jobs$experience_max <- as.numeric(jobs$experience_max)
  exp_inverted <- !is.na(jobs$experience_min) & !is.na(jobs$experience_max) & jobs$experience_min > jobs$experience_max
  if (any(exp_inverted)) {
    tmp <- jobs$experience_min[exp_inverted]
    jobs$experience_min[exp_inverted] <- jobs$experience_max[exp_inverted]
    jobs$experience_max[exp_inverted] <- tmp
  }
  
  # 3. Deduplicate Jobs
  dedup_res <- deduplicate_jobs(jobs)
  jobs_cleaned <- dedup_res$jobs
  removed_job_ids <- dedup_res$removed_ids
  
  # 4. Clean Skills Table & Remove Orphaned Skills
  message("Cleaning and standardizing skills dataset...")
  
  # Filter out skills belonging to removed duplicate jobs
  if (length(removed_job_ids) > 0) {
    skills <- skills[!skills$job_id %in% removed_job_ids, ]
  }
  
  # Normalize each skill
  norm_skills <- lapply(skills$skill_raw, normalize_skill)
  skills$skill_name <- sapply(norm_skills, function(x) x$name)
  skills$skill_category <- sapply(norm_skills, function(x) x$category)
  skills$is_required <- ifelse(is.na(skills$is_required), TRUE, as.logical(skills$is_required))
  
  # Remove exact duplicate skills per job_id
  dup_skills <- duplicated(skills[, c("job_id", "skill_name")])
  if (any(dup_skills)) {
    message(sprintf("Removed %d duplicate skill entries within individual jobs.", sum(dup_skills)))
    skills_cleaned <- skills[!dup_skills, ]
  } else {
    skills_cleaned <- skills
  }
  
  # 5. Write Processed Outputs
  write.csv(jobs_cleaned, file = jobs_output_path, row.names = FALSE, na = "NA")
  write.csv(skills_cleaned, file = skills_output_path, row.names = FALSE, na = "NA")
  
  message(sprintf("\n✅ Cleaning complete!"))
  message(sprintf("Jobs:   %d raw -> %d cleaned (Removed %d duplicates)", 
                  n_jobs_raw, nrow(jobs_cleaned), dedup_res$removed_count))
  message(sprintf("Skills: %d raw -> %d cleaned", n_skills_raw, nrow(skills_cleaned)))
  message(sprintf("Saved cleaned jobs to:   %s", jobs_output_path))
  message(sprintf("Saved cleaned skills to: %s", skills_output_path))
  
  invisible(list(jobs = jobs_cleaned, skills = skills_cleaned))
}

if (sys.nframe() == 0) {
  clean_pipeline_datasets()
}
