# ==============================================================================
# TechScape: Testthat Suite for Empirical Data Quality & Provenance
# ==============================================================================

test_that("empirical job dataset preserves provenance and zero-fabrication guarantees", {
  jobs_path <- "data/real_sample/jobs_real_sample.csv"
  skip_if_not(file.exists(jobs_path), "Empirical jobs file missing")

  real_jobs <- read.csv(jobs_path, stringsAsFactors = FALSE)

  # Check dataset size
  expect_equal(nrow(real_jobs), 80)

  # Zero synthetic data
  expect_true(all(real_jobs$is_synthetic == FALSE))

  # Provenance tracking
  expect_true(all(!is.na(real_jobs$source) & real_jobs$source != ""))
  expect_true(all(grepl("^http", real_jobs$source_url)))
  expect_true(all(grepl("^2026-", real_jobs$collection_date)))
  expect_true(all(!is.na(real_jobs$original_title) & real_jobs$original_title != ""))
})

test_that("skills dataset maintains referential integrity to jobs table", {
  jobs_path <- "data/real_sample/jobs_real_sample.csv"
  skills_path <- "data/real_sample/job_skills_real_sample.csv"
  skip_if_not(file.exists(jobs_path) && file.exists(skills_path), "Data files missing")

  real_jobs <- read.csv(jobs_path, stringsAsFactors = FALSE)
  real_skills <- read.csv(skills_path, stringsAsFactors = FALSE)

  # No orphan skills
  orphan_skills <- setdiff(real_skills$job_id, real_jobs$job_id)
  expect_equal(length(orphan_skills), 0)

  # Valid non-empty skill names
  expect_true(all(!is.na(real_skills$skill_name) & real_skills$skill_name != ""))
})

test_that("compensation and experience bounds adhere to logical constraints", {
  jobs_path <- "data/real_sample/jobs_real_sample.csv"
  skip_if_not(file.exists(jobs_path), "Empirical jobs file missing")

  real_jobs <- read.csv(jobs_path, stringsAsFactors = FALSE)

  # Missing salaries preserved as NA
  undisclosed <- subset(real_jobs, is.na(salary_min))
  expect_true(all(is.na(undisclosed$salary_min) & is.na(undisclosed$salary_max)))

  # Disclosed salaries positive
  disclosed_lkr <- subset(real_jobs, currency == "LKR" & !is.na(salary_min))
  expect_true(all(disclosed_lkr$salary_min > 0))
  expect_true(all(disclosed_lkr$salary_max >= disclosed_lkr$salary_min))

  # Experience non-negative
  expect_true(all(real_jobs$experience_min >= 0, na.rm = TRUE))

  # Valid seniority tiers
  valid_seniority <- c("Intern", "Junior", "Mid", "Senior", "Lead")
  expect_true(all(real_jobs$seniority_level %in% valid_seniority))
})

test_that("macroeconomic indicators dataset contains realistic national bounds", {
  macro_path <- "data/processed/macro_labour_indicators.csv"
  skip_if_not(file.exists(macro_path), "Macro indicators missing")

  macro <- read.csv(macro_path, stringsAsFactors = FALSE)

  expect_true(any(macro$indicator_name == "National Unemployment Rate"))
  unemp_rows <- subset(macro, grepl("Unemployment", indicator_name))
  expect_true(all(unemp_rows$value > 0 & unemp_rows$value < 30))
})
