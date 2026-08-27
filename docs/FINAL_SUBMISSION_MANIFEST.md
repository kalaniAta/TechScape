# TechScape: Final Submission Manifest

This manifest enumerates all primary assets, scripts, data tiers, test suites, figures, tables, and academic reports comprising the TechScape submission package.

---

## 1. Primary Source Datasets

| File Path | Description / Purpose | Tier Classification |
|---|---|:---:|
| `data/real_sample/jobs_real_sample.csv` | 80 verified Sri Lankan IT job postings across 39 tech employers with full provenance | **VERIFIED REAL** |
| `data/real_sample/job_skills_real_sample.csv` | 290 extracted technical skill mappings linked via relational foreign keys | **VERIFIED REAL** |
| `data/processed/macro_labour_indicators.csv` | 31 official time series indicators from DCS LFS and CBSL Annual Reports | **OFFICIAL MACRO** |
| `data/synthetic/jobs_synthetic_dev.csv` | 300 synthetic records used for pipeline stress testing | **SYNTHETIC TEST** |
| `data/synthetic/job_skills_synthetic_dev.csv` | 1,316 synthetic skill associations for pipeline stress testing | **SYNTHETIC TEST** |
| `data/reference/jobs_inferred_reference.csv` | 60 reference records used exclusively for schema and regex design | **INFERRED REF** |

---

## 2. Core Analysis & Statistical Pipeline Scripts

| File Path | Description / Purpose |
|---|---|
| `R/01_import.R` | Data ingestion engine with file presence, schema, and structure checks |
| `R/02_validate.R` | Referential integrity and bounds validation engine |
| `R/03_clean.R` | Data cleaning, title canonicalization, and deduplication engine |
| `R/04_transform.R` | Feature engineering, experience/salary banding, and entry-level tagging |
| `R/05_job_market_analysis.R` | Career category distribution and volume dynamics (RQ1, RQ2) |
| `R/06_skills_analysis.R` | Technical skill penetration rates and domain categorization (RQ3) |
| `R/07_salary_analysis.R` | Compensation distribution, disclosure rate, and currency dynamics (RQ6) |
| `R/08_experience_analysis.R` | Experience requirement distributions and accessibility (RQ4, RQ5) |
| `R/09_employment_analysis.R` | Macroeconomic national/youth unemployment and ICT export analysis (RQ7) |
| `R/10_industry_evolution_analysis.R` | Work mode flexibility and cloud stack adoption modeling (RQ8) |
| `R/11_run_real_analysis_pipeline.R` | Verified empirical analytical pipeline runner |
| `R/12_inferential_statistics.R` | Formal statistical hypothesis testing engine (KW, Fisher, Pearson, Wilcoxon) |
| `R/13_run_complete_ecosystem.R` | Master single-command orchestration runner |

---

## 3. Automated Test Suites

| File Path | Purpose | Assertions / Stages | Pass Status |
|---|---|:---:|:---:|
| `tests/data_quality/test_real_and_inferential.R` | Provenance, bounds, referential integrity, and macro bounds | 16 assertions | **100% PASS** |
| `tests/data_quality/test_cleaning_transform.R` | End-to-end cleaning and transformation regression suite | 5 pipeline stages | **100% PASS** |
| `tests/data_quality/test_validation.R` | Schema and validation function constraint tests | 4 test cases | **100% PASS** |
| `tests/data_quality/audit_recalculate_metrics.R` | Independent recalculation of all empirical metrics directly from raw data | Complete audit | **100% PASS** |

---

## 4. Interactive Dashboard Platform

| File Path | Description |
|---|---|
| `dashboard/index.html` | Standalone glassmorphic responsive HTML interface |
| `dashboard/styles.css` | Modern dark theme stylesheet with responsive grid and micro-animations |
| `dashboard/app.js` | Client-side reactive JavaScript filter engine and dynamic chart renderers |
| `dashboard/data.js` | Verified JSON data bundle powering the standalone dashboard |
| `dashboard/generate_dashboard_data.R` | R export engine serializing processed data into `data.js` |
| `dashboard/app.R` | Companion native R Shiny application |

---

## 5. Primary Academic Synthesis Reports

| File Path | Description |
|---|---|
| `outputs/findings/final_academic_synthesis_report.md` | Comprehensive academic evaluation structured across findings, tests, interpretations, and limits |
| `outputs/findings/final_methodology_summary.md` | Formal methodology, data governance, and feature engineering treatise |
| `outputs/findings/final_results_summary.md` | Recalculated empirical metrics, skills demand tables, and hypothesis decisions |
| `outputs/findings/final_limitations.md` | Academic limitations, selection bias, and epistemic boundaries |
| `outputs/findings/final_repository_audit.md` | Independent verification report with complete health and test audit |
| `outputs/findings/student_career_insights_handbook.md` | Evidence-informed career guide for Sri Lankan IT undergraduates |
