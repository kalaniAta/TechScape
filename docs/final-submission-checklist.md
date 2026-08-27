# TechScape: Final Academic Submission Checklist

This checklist confirms the verification, provenance, statistical integrity, and reproducibility status of the TechScape repository prior to final academic evaluation and dissertation submission.

---

## 1. Data Governance & Provenance Checklist

- [x] **Strict Data Tier Isolation:**
  - `data/synthetic/` contains ONLY synthetic test data (300 records).
  - `data/reference/` contains ONLY inferred reference templates (60 records).
  - `data/real_sample/` contains ONLY verified empirical records (80 jobs, 290 skills).
- [x] **Zero Fabrication Compliance:**
  - 0 synthetic records exist in `data/real_sample/`.
  - 0 inferred records exist in `data/real_sample/`.
  - All 80 real job postings have authentic provenance (`source`, `source_url`, `collection_date`, `source_job_id`).
  - Unmodified original text fields (`original_title`, `original_salary`, `original_experience`) are preserved alongside standardized variables.
- [x] **Referential Integrity:**
  - All 290 skill associations in `job_skills_real_sample.csv` map to valid `job_id` foreign keys in `jobs_real_sample.csv` (0 orphans).

---

## 2. Statistical & Methodological Verification

- [x] **Accurate Sample Parameters:**
  - Real job sample size: $n = 80$ across 39 unique organizations.
  - Software Engineering share: 25.00% (20/80).
  - Data & AI / ML share: 13.75% (11/80).
  - Cloud & DevOps share: 12.50% (10/80).
  - QA & Test Automation share: 11.25% (9/80).
  - Cyber Security share: 10.00% (8/80).
  - IT Systems / Infrastructure share: 10.00% (8/80).
  - Management & BA share: 8.75% (7/80).
  - UI/UX & Product Design share: 8.75% (7/80).
  - Entry-level accessibility: 26.25% (21/80).
  - Salary non-disclosure: 56.25% (45/80).
  - Median disclosed LKR salary: LKR 330,000 (IQR: LKR 310,000; $n = 26$).
  - Disclosed USD-pegged contracts: 25.71% ($n = 9$ of 35 disclosed; Median USD $1,600).
- [x] **Verified Statistical Test Decisions:**
  - Kruskal-Wallis Test (Experience by Career Track): $\chi^2 = 14.243$, $df = 7$, $p = 0.0470$ (Statistically significant at $\alpha = 0.05$).
  - Fisher's Exact Test (Salary Disclosure by Work Mode): Odds Ratio = 0.558, $p = 0.3126$ (Not significant).
  - Pearson Correlation (Experience vs LKR Salary): $r = 0.955$, $t = 15.79$, $df = 24$, $p < 0.00001$, 95% CI: $[0.901, 0.980]$; Spearman $\rho = 0.915$.
  - Wilcoxon Rank-Sum Test (Skill Density by Seniority): $W = 761.0$, $p = 0.0880$ (Not statistically significant at $\alpha = 0.05$).
- [x] **Absence of Causal Overreach:**
  - All results framed as observational associations within the sample; zero causal claims.
  - Zero predictive machine learning or automated career scoring models.

---

## 3. Macroeconomic Integration & Non-Conflation

- [x] **Authoritative Macroeconomic Datasets:**
  - Department of Census & Statistics (DCS) Labour Force Survey (LFS) 2016–2026 Q1 indicators.
  - Central Bank of Sri Lanka (CBSL) BPM6 Telecommunications, Computer & Info Service Export Earnings 2019–2025.
- [x] **Principle of Non-Conflation:**
  - National labor force stock (macroeconomic) is strictly distinguished from online job vacancy flow (micro-level hiring demand).

---

## 4. Software & Dashboard Platform

- [x] **Python Ingestion & Preprocessing Layer:** Modular API interface (`api_fetcher.py`), heterogeneous adapters (`source_adapters.py`), encoding hygiene (`text_hygiene.py`), and pre-flight schema provenance assertions (`raw_validator.py`).
- [x] **Master Cross-Platform CLI Orchestrator:** `python python/runner.py` coordinates Python pre-flight validation, R econometric execution, and artifact verification.
- [x] **Interactive Web Dashboard:** Standalone responsive application in `dashboard/index.html` with dynamic cross-filtering, live KPI ribbons, and raw posting explorer.
- [x] **R Shiny App:** Native R Shiny implementation in `dashboard/app.R`.
- [x] **Automated Test Suites:** Python unit test suite (`tests/test_python_pipeline.py`, 13 assertions) and 4 R data quality suites in `tests/data_quality/` with 100% pass rate.
- [x] **Single Command Reproducibility:** Master runners (`python python/runner.py` and `R/13_run_complete_ecosystem.R`) regenerate all outputs from clean state with exit code 0.
