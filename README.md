# TechScape: Sri Lankan IT Labour Market Analytics & Industry Evolution Analysis

[![Python](https://img.shields.io/badge/Python-3.14-blue.svg)](python/)
[![R Execution](https://img.shields.io/badge/R-4.6.1-blue.svg)](https://www.r-project.org/)
[![Data Provenance](https://img.shields.io/badge/Data_Provenance-100%25_Verified-success.svg)](data/real_sample/)
[![Zero Fabrication](https://img.shields.io/badge/Zero_Fabrication-Guaranteed-green.svg)](docs/methodology.md)
[![Status](https://img.shields.io/badge/Academic_Status-Submission_Ready-purple.svg)](docs/final-submission-checklist.md)

**TechScape** is an academic, data-driven analytical platform that investigates the structural evolution of the **Sri Lankan IT labour market**. Sourced from verified empirical job postings and official national macroeconomic datasets, the system employs a **hybrid Python + R architecture**: Python provides modular raw data ingestion, text hygiene, and pre-flight schema provenance verification, while R executes core econometric modeling, non-parametric statistical hypothesis testing, publication-grade `ggplot2` visualization, and interactive dashboards.

> **🛡️ DATA GOVERNANCE & PROVENANCE STANDARD**
> TechScape strictly maintains a three-tier data classification policy. Synthetic data ($n=300$) is used solely for pipeline stress testing. Inferred reference records ($n=60$) are used exclusively for schema and regex design. Empirical conclusions are derived **exclusively from 80 verified Sri Lankan IT job postings** with 100% traceable provenance and official statistics from the **Department of Census & Statistics (DCS)** and **Central Bank of Sri Lanka (CBSL)**.

---

## 1. Core Research Questions (RQ1–RQ8)

| Research Question | Focus Area | Primary Empirical Finding |
|---|---|---|
| **RQ1: Volume & Trends** | Advertised Vacancies & Growth | CBSL ICT service export earnings expanded from **USD $985M (2019)** to **USD $1,520M (2025)** (+54.3% growth). |
| **RQ2: Career Tracks** | Market Composition by Category | Software Engineering represents **25.00%**, Data/AI **13.75%**, Cloud/DevOps **12.50%**, QA **11.25%**, Security **10.00%**, Systems **10.00%**. |
| **RQ3: Skills Demand** | Technical Stack Penetration | Python (11.25%), Kubernetes (10.00%), Figma (8.75%), Linux (8.75%), PostgreSQL (8.75%), SQL (8.75%), Java (7.50%), React (7.50%), TypeScript (7.50%). |
| **RQ4: Accessibility** | Entry-Level Opportunities | **26.25%** of postings (21 of 80) accept candidates with $\le 1$ year of experience or intern/associate seniority. |
| **RQ5: Experience** | Experience Thresholds Spread | Mean required experience is **3.12 years**; median is **3.00 years** (IQR: 4.00 years, range: 0–8 years). |
| **RQ6: Compensation** | Salary & Currency Dynamics | 43.75% salary disclosure rate. Disclosed LKR median is **LKR 330,000/month** (IQR: LKR 310,000; $n=26$). **25.71%** of disclosed salaries are USD-pegged (median USD $1,600). |
| **RQ7: Macro Context** | National Unemployment & Youth | National unemployment stabilized at **3.7% in Q1 2026** (DCS LFS). Youth unemployment (20–29) stands at **12.8%**. |
| **RQ8: Adaptability** | Work Mode & Stack Evolution | **65.00%** Hybrid, **26.25%** On-site, **8.75%** Remote. High penetration of containerization (Docker/Kubernetes). |

---

## 2. Hybrid Architecture (Python Ingestion → R Analytics)

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PYTHON INGESTION LAYER                           │
│  • python/ingestion/api_fetcher.py     : Modular API interface & mock client│
│  • python/ingestion/source_adapters.py : JSON/CSV/TSV heterogeneous adapters│
│  • python/preprocessing/text_hygiene.py: UTF-8 BOM, encoding & text hygiene │
│  • python/preprocessing/raw_validator.py: Provenance & referential integrity│
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (Standardized CSV Handoff)
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            R ANALYTICAL PIPELINE                            │
│  • R/01_import.R to R/04_transform.R   : Normalization & feature engineering│
│  • R/05_ to R/10_                      : Descriptive domain analysis        │
│  • R/12_inferential_statistics.R       : Kruskal-Wallis, Fisher, Pearson    │
│  • outputs/figures/ (27 ggplot2 PNGs)  : 300 DPI publication visualizations │
│  • dashboard/app.R & dashboard/index.html: Shiny & Web UI exploration       │
└──────────────────────────────────────▲──────────────────────────────────────┘
                                       │
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                        MASTER ORCHESTRATOR CLI                              │
│  python python/runner.py                                                    │
│  • Coordinates Python preflight checks → R analytical execution → Auditing  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Statistical Hypothesis Testing Decisions

TechScape applies formal non-parametric and parametric inferential tests to the empirical sample:

1. **Experience Requirements Across Career Categories (Kruskal-Wallis Test):**
   - $\chi^2 = 14.243$, $df = 7$, $p = 0.0470$ $\rightarrow$ **Statistically Significant ($p < 0.05$)**. Significant distributional differences in required experience exist between tracks (e.g. Lead/Architecture vs IT Support).
2. **Salary Disclosure by Work Mode Flexibility (Fisher's Exact Test):**
   - $\text{Odds Ratio} = 0.558$, $p = 0.3126$ $\rightarrow$ **Not Statistically Significant ($p \ge 0.05$)**. Salary disclosure does not depend on remote/hybrid status.
3. **Experience vs. Disclosed LKR Salary Association (Pearson & Spearman Correlation):**
   - Pearson $r = 0.955$, $t = 15.79$, $df = 24$, $p < 0.00001$ (95% CI: $[0.901, 0.980]$); Spearman $\rho = 0.915$ $\rightarrow$ **Statistically Significant ($p < 0.001$)**. Very strong positive linear relationship between experience and compensation.
4. **Skill Breadth by Seniority Tier (Wilcoxon Rank-Sum Test):**
   - $W = 761.0$, $p = 0.0880$ $\rightarrow$ **Not Statistically Significant ($p \ge 0.05$)**. Entry-level roles average 3.43 skills vs 3.70 skills in experienced roles.

---

## 4. Interactive Web Dashboard & R Shiny App

- **Standalone Web Dashboard:** Open [`dashboard/index.html`](dashboard/index.html) in any web browser. Features dynamic cross-filtering by Career Track, Seniority Tier, and Work Mode, interactive SVG charts, KPI ribbons, and a live raw posting explorer.
- **R Shiny Application:** Run [`dashboard/app.R`](dashboard/app.R) in RStudio.

---

## 5. Repository Structure

```text
TechScape/
├── README.md                                  # Evaluator overview & quickstart
├── python/                                    # Python Ingestion & Preprocessing Layer
│   ├── ingestion/
│   │   ├── api_fetcher.py                     # Extensible API ingestion & mock client
│   │   └── source_adapters.py                 # Multi-format (JSON/CSV/TSV) raw adapters
│   ├── preprocessing/
│   │   ├── text_hygiene.py                    # Encoding, BOM & control character sanitization
│   │   └── raw_validator.py                   # Provenance & referential integrity validation
│   └── runner.py                              # Master CLI orchestrator
├── docs/
│   ├── project-specification.md               # Scope and non-goals
│   ├── research-questions.md                  # RQ1–RQ8 specifications
│   ├── data-source-register.md                # Data sources & provenance register
│   ├── data-dictionary.md                     # Comprehensive entity schema
│   ├── methodology.md                         # Cleaning, transforming & analysis design
│   ├── data-limitations.md                    # Academic methodology & limitations
│   └── final-submission-checklist.md          # Submission verification checklist
├── data/
│   ├── raw/                                   # Macro indicators (DCS/CBSL)
│   ├── synthetic/                             # Development test dataset (300 records)
│   ├── reference/                             # Inferred taxonomy template (60 records)
│   ├── real_sample/                           # Verified empirical postings (80 records, 290 skills)
│   └── processed/                             # Analysis-ready cleaned & transformed CSVs
├── R/
│   ├── 01_import.R & 02_validate.R            # Ingestion & schema validation
│   ├── 03_clean.R & 04_transform.R            # Normalization & feature engineering
│   ├── 05_job_market_analysis.R               # Category volume & distribution (RQ1, RQ2)
│   ├── 06_skills_analysis.R                   # Technical skill penetration (RQ3)
│   ├── 07_salary_analysis.R                   # Compensation & currency dynamics (RQ6)
│   ├── 08_experience_analysis.R               # Experience spreads & accessibility (RQ4, RQ5)
│   ├── 09_employment_analysis.R               # Macroeconomic DCS & CBSL analysis (RQ7)
│   ├── 10_industry_evolution_analysis.R       # Work mode & stack evolution (RQ8)
│   ├── 11_run_real_analysis_pipeline.R        # Real empirical pipeline runner
│   ├── 12_inferential_statistics.R            # Hypothesis testing engine
│   └── 13_run_complete_ecosystem.R            # Master end-to-end ecosystem runner
├── dashboard/
│   ├── index.html, styles.css, app.js         # Interactive standalone web dashboard
│   ├── data.js                                # Structured empirical JSON bundle
│   ├── generate_dashboard_data.R              # R exporter script
│   └── app.R                                  # R Shiny application
├── outputs/
│   ├── figures/                               # 27 Publication-quality figures (.png)
│   ├── tables/                                # 35 Structured analytical tables (.csv)
│   └── findings/                              # Academic synthesis & findings reports (.md)
└── tests/
    ├── data_quality/                          # Automated R data quality & integrity test suites
    └── test_python_pipeline.py                # Automated Python unit test suite
```

---

## 6. End-to-End Reproducibility Instructions

Execute the entire hybrid analytical ecosystem with a single command from either Python or R:

### Option A: Python Master Orchestrator (Recommended)
```bash
python python/runner.py
```

### Option B: Direct R Ecosystem Runner
```powershell
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" R/13_run_complete_ecosystem.R
```

This single command:
1. Validates text encoding, UTF-8 compliance, and schema provenance via Python pre-flight checks.
2. Ingests and validates verified real postings ($n=80$) and macro indicators.
3. Executes data cleaning, canonical standardization, and feature engineering in R.
4. Computes all descriptive statistics, non-parametric percentiles, and correlations.
5. Executes inferential hypothesis tests ($p$-values, effect sizes).
6. Generates 27 publication figures and 35 tabular datasets.
7. Re-exports the interactive dashboard bundle (`dashboard/data.js`).
8. Runs all automated data quality test suites in Python (13 assertions) and R (16 assertions) with 100% pass verification.

