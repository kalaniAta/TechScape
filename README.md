# TechScape: Sri Lankan IT Labour Market Analytics

**Empirical analysis & visualization platform investigating the structural evolution of Sri Lanka's IT industry through verified job postings and macroeconomic indicators.**

[![Python](https://img.shields.io/badge/Python-3.x-blue.svg)](python/)
[![R](https://img.shields.io/badge/R-4.6.1-blue.svg)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-29%20Assertions-brightgreen.svg)](#testing)
[![Data Verified](https://img.shields.io/badge/Data-100%25_Verified-success.svg)](data/real_sample/)

## Value Proposition

TechScape transforms fragmented job market data into actionable insights for IT students, educators, and researchers. Using **80 verified job postings** and official macro indicators, it quantifies how Sri Lanka's IT labour market has evolved across hiring categories, skills demand, experience requirements, compensation, and work flexibility.

---

## Key Capabilities

- 📊 **Empirical Analysis:** 8 research questions answered with statistical rigor (Kruskal-Wallis, Fisher, Pearson, Wilcoxon)
- 📈 **Hybrid Architecture:** Python data ingestion + R analytical pipeline with automated validation
- 🎨 **Publication Quality:** 27 production figures (300 DPI PNG) + 35 tabular datasets
- 📱 **Interactive Dashboard:** Standalone web UI (no server required) + R Shiny companion app
- 🔒 **Rigorous Data Governance:** Zero fabrication; all real data explicitly sourced and provenance-tracked
- ✅ **Reproducible:** Single command generates entire analytical ecosystem

---

## Quick Start

### Prerequisites
- **Python 3.x** (standard library only, no external packages)
- **R 4.6.1+** with tidyverse, ggplot2, stringr, lubridate

### Run Complete Pipeline
```bash
# Master orchestrator (Python preflight + R analysis + verification)
python python/runner.py

# Or run R pipeline directly
Rscript R/13_run_complete_ecosystem.R
```

**Output:** Generates 27 figures, 35 tables, and interactive dashboard in `outputs/` and `dashboard/`

### Explore Dashboard
```bash
# Standalone web interface (no installation required)
open dashboard/index.html

# Or run R Shiny app
Rscript -e "shiny::runApp('dashboard')"
```

---

## Architecture & Data Pipeline

```
DATA SOURCES
├── Real Job Postings (80 verified records)
├── Synthetic Dev Data (300 records for testing)
├── Macro Indicators (DCS LFS, CBSL ICT exports)
└── Reference Taxonomy (60 inferred records)
          ↓
     PYTHON LAYER
  (Validation & Preprocessing)
├── Text hygiene (UTF-8, BOM removal)
├── Schema validation
├── Referential integrity checks
└── Standardized CSV output
          ↓
     R ANALYTICAL PIPELINE
  (Analysis & Visualization)
├── Data import & validation
├── Cleaning & normalization
├── Feature engineering
├── 8 domain analysis modules (RQ1–RQ8)
├── Statistical hypothesis testing
└── Figure & table generation
          ↓
    OUTPUT ARTIFACTS
├── 27 figures (PNG, 300 DPI)
├── 35 tables (CSV)
├── Markdown findings reports
└── Interactive JSON dashboard
```

---

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Data Ingestion | Python 3.x | API clients, multi-format adapters (JSON/CSV/TSV), text validation |
| Analysis | R 4.6.1 | Statistical modeling, hypothesis testing, figure generation |
| Visualization | ggplot2, D3.js | Publication-quality static plots, interactive dashboards |
| Dashboard | HTML5, CSS3, JavaScript | Standalone web UI (no Node.js/npm required) |
| Testing | unittest (Python), base R | Automated validation (29 total assertions) |
| Orchestration | Python subprocess | Cross-platform R script execution |

---

## Core Research Questions

| RQ | Question | Finding (Real Data, n=80) |
|---|---|---|
| **RQ1** | Volume & growth in IT vacancies? | CBSL ICT exports: USD $985M (2019) → USD $1,520M (2025) |
| **RQ2** | Career category distribution? | Software Engineering (25%), Data/AI (13.75%), Cloud/DevOps (12.5%) |
| **RQ3** | Top technical skills demanded? | Python (11.25%), Kubernetes (10%), Figma (8.75%), Linux (8.75%) |
| **RQ4** | Entry-level accessibility? | **26.25%** (21 of 80) for candidates with ≤1 year experience |
| **RQ5** | Experience requirement spreads? | Mean: 3.12 years, Median: 3.00 years (IQR: 4.00, range: 0–8) |
| **RQ6** | Salary & currency dynamics? | 43.75% disclosure; Median LKR: 330,000/month (IQR: 310,000) |
| **RQ7** | Macro labour context? | National unemployment: 3.7% (Q1 2026); Youth: 12.8% |
| **RQ8** | Work mode & stack evolution? | 65% Hybrid, 26.25% On-site, 8.75% Remote |

**Full methodology & limitations:** See [`docs/`](docs/) for detailed specifications, data dictionary, and statistical methodology.

---

## Dashboard Preview

**Interactive web dashboard** features:
- Dynamic filtering by Career Track, Seniority Tier, Work Mode
- Career category distribution charts
- Skills demand heatmaps
- Salary & experience correlations
- Employment context (national unemployment trends)

**Access modes:**
1. **Standalone HTML:** Open [`dashboard/index.html`](dashboard/index.html) in any browser
2. **R Shiny App:** `Rscript -e "shiny::runApp('dashboard')"`

---

## Repository Structure

```
TechScape/
├── README.md                           # This file
├── LICENSE                             # Apache 2.0
├── .gitignore
│
├── python/                             # Ingestion & Validation Layer
│   ├── runner.py                       # Master orchestrator CLI
│   ├── ingestion/
│   │   ├── api_fetcher.py              # Mock API client + macro fetcher
│   │   └── source_adapters.py          # JSON/CSV/TSV adapters
│   └── preprocessing/
│       ├── text_hygiene.py             # UTF-8 validation, BOM removal
│       └── raw_validator.py            # Schema & integrity checks
│
├── R/                                  # Analytical Pipeline
│   ├── 01_import.R                     # Typed data import
│   ├── 02_validate.R                   # Comprehensive validation
│   ├── 03_clean.R                      # Normalization & deduplication
│   ├── 04_transform.R                  # Feature engineering
│   ├── 05-10_*_analysis.R              # Domain analysis (RQ1–RQ8)
│   ├── 11_run_real_analysis_pipeline.R # Empirical execution
│   ├── 12_inferential_statistics.R     # Hypothesis testing
│   ├── 13_run_complete_ecosystem.R     # Master runner
│   └── generate_synthetic_data.R       # Synthetic dataset generator
│
├── data/
│   ├── real_sample/                    # 80 verified postings + 302 skills
│   │   └── README.md                   # Provenance documentation
│   ├── synthetic/                      # 300 records for testing
│   ├── reference/                      # 60 inferred taxonomy records
│   ├── raw/                            # Official macro indicators
│   └── processed/                      # Analysis-ready CSVs (generated)
│
├── docs/
│   ├── project-specification.md        # Scope & objectives
│   ├── research-questions.md           # RQ1–RQ8 specifications
│   ├── data-dictionary.md              # Field definitions & types
│   ├── data-source-register.md         # Data provenance
│   ├── methodology.md                  # Analysis methodology
│   ├── data-limitations.md             # Statistical & sampling limitations
│   ├── FINAL_EVALUATOR_GUIDE.md        # Executive summary
│   └── FINAL_SUBMISSION_MANIFEST.md    # Submission checklist
│
├── dashboard/
│   ├── index.html                      # Standalone web UI
│   ├── app.js                          # Frontend logic
│   ├── styles.css                      # Responsive design
│   ├── data.js                         # JSON dataset (generated)
│   ├── app.R                           # Optional R Shiny app
│   └── generate_dashboard_data.R       # JSON export script
│
├── outputs/ (generated by pipeline)
│   ├── figures/                        # 27 PNG figures (300 DPI)
│   ├── tables/                         # 35 CSV tables
│   └── findings/                       # Markdown reports
│
├── tests/
│   ├── test_python_pipeline.py         # 13 Python assertions
│   └── data_quality/
│       └── test_real_and_inferential.R # 16 R assertions
│
└── .github/workflows/
    └── test.yml                        # GitHub Actions CI
```

---

## Data Governance & Provenance

**Three-tier classification:**

| Tier | Records | Purpose | Usage |
|------|---------|---------|-------|
| **Real Sample** | 80 jobs, 302 skills | Empirical job market evidence | Final findings |
| **Synthetic Dev** | 300 jobs, 600+ skills | Pipeline testing | Development only |
| **Reference** | 60 jobs, 221 skills | Taxonomy validation | Regex & rule design |

**Key guarantees:**
- ✅ All real data explicitly sourced from public job listings (TopJobs, LinkedIn, ITPro Sri Lanka)
- ✅ Every record includes source URL, collection date, source job ID
- ✅ Raw fields preserved alongside normalized analytical variables
- ✅ **Zero fabrication:** All empirical findings from verified records only
- ✅ Synthetic data clearly flagged and segmented (never mixed with real data)

See [`data/real_sample/README.md`](data/real_sample/README.md) for full provenance disclosure.

---

## Reproducibility

**Guarantees:**
- Single-command reproducibility from clean state
- All dependencies auto-detected (Python + R)
- Automated preflight validation (text encoding, schema, referential constraints)
- 29 total test assertions executed end-to-end
- Cross-platform support (Windows, Linux, macOS)

**Validation pipeline:**
```
python python/runner.py
  → [1/3] Python pre-flight hygiene & schema validation
  → [2/3] R analytical pipeline (13 modules)
  → [3/3] Academic artifact verification (29 assertions)
  ✅ Result: 100% pass rate
```

---

## Testing

### Python Tests (13 assertions)
```bash
python -m unittest tests.test_python_pipeline
```
- Text hygiene validation (UTF-8, BOM detection)
- Source adapters (JSON/CSV/TSV parsing)
- API fetcher mocking
- Schema & referential integrity checks

### R Tests (16 assertions)
Automated in R/13_run_complete_ecosystem.R:
- Data quality validation
- Logical bounds on numeric fields
- Foreign key integrity
- Provenance tracking

### Integrated Testing
```bash
python python/runner.py  # Runs all tests automatically
```

---

## Statistical Methodology

TechScape applies formal inferential testing to the empirical sample (n=80):

| Hypothesis | Test | Statistic | p-value | Decision |
|-----------|------|-----------|---------|----------|
| Experience differs by career | Kruskal-Wallis | χ² = 14.243 | 0.0470 | **Significant** |
| Salary disclosure depends on work mode | Fisher's Exact | OR = 0.558 | 0.3126 | Not significant |
| Experience correlates with LKR salary | Pearson | r = 0.955 | <0.00001 | **Highly significant** (95% CI: [0.901, 0.980]) |
| Skill breadth differs by seniority | Wilcoxon | W = 761.0 | 0.0880 | Not significant |

**Important:** All results describe this specific sample (n=80, August 2026, Colombo-centric platforms). Not generalizable to entire Sri Lankan IT workforce. See [`docs/data-limitations.md`](docs/data-limitations.md) for caveats.

---

## Known Limitations

1. **Sample Size:** n=80 verified postings (illustrative sample, not census)
2. **Salary Disclosure:** 56.5% use qualitative terms ("Negotiable," "Competitive")
3. **Geographic Bias:** Colombo-centric (TopJobs, LinkedIn platforms)
4. **Temporal Snapshot:** Cross-sectional (August 2026), not historical trend
5. **Industry Scope:** IT-BPM export firms; excludes domestic-only IT companies

See [`docs/data-limitations.md`](docs/data-limitations.md) for comprehensive discussion.

---

## Intended Audience

- **IT Students & Undergraduates:** Understand labour market structure and skills
- **Educators & Career Counselors:** Reference data for curriculum and guidance
- **Labour Market Researchers:** Empirical foundation for Sri Lankan IT analysis
- **Technical Recruiters:** Benchmark skills, experience, and compensation

---

## Setup & Dependencies

### Python
No external package dependencies. Uses only Python 3.x standard library.

### R
Auto-loads required packages on first script execution:
```R
install.packages(c("tidyverse", "ggplot2", "stringr", "lubridate", "tidyr", "shiny"))
```

### CI/CD
GitHub Actions workflow (`.github/workflows/test.yml`) automatically:
- Runs Python unit tests on each commit
- Validates data preflight checks
- Reports artifact integrity

---

## License

Licensed under the **Apache License 2.0**. See [`LICENSE`](LICENSE) for terms.

---

## Documentation

Comprehensive technical documentation in [`docs/`](docs/):

- **[`project-specification.md`](docs/project-specification.md)** — Scope, objectives, non-goals
- **[`research-questions.md`](docs/research-questions.md)** — Detailed RQ1–RQ8 specifications
- **[`data-dictionary.md`](docs/data-dictionary.md)** — Field definitions, types, valid values
- **[`data-source-register.md`](docs/data-source-register.md)** — Data provenance & collection
- **[`methodology.md`](docs/methodology.md)** — Analysis & hypothesis testing methodology
- **[`data-limitations.md`](docs/data-limitations.md)** — Statistical & sampling limitations
- **[`FINAL_EVALUATOR_GUIDE.md`](docs/FINAL_EVALUATOR_GUIDE.md)** — Executive technical summary

---

**Status:** Research Complete | **Last Updated:** August 2026 | **Data Collection:** August 2026
