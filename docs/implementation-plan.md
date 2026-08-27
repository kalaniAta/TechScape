# TechScape: Multi-Phase Implementation Plan

## 1. Plan Overview

This document specifies the multi-phase implementation roadmap for the TechScape analytical system. Development proceeds sequentially through defined phases, with explicit verification gates at each milestone.

---

## 2. Phase Breakdown & Milestones

```text
Phase 0: Project Initialization & Repository Setup   [Milestone 1 - Current]
Phase 1: Data Requirements & Real Sample Curation    [Milestone 1 - Current]
Phase 2: Data Model & Standardization Taxonomies     [Milestone 1 - Current]
Phase 3: Real-Informed Synthetic Data Generator      [Milestone 1 - Current]
Phase 4: R Data Cleaning & Transformation Pipeline   [Milestone 2]
Phase 5: Core Exploratory & Statistical Analysis     [Milestone 2]
Phase 6: Analytical Visualizations (ggplot2)         [Milestone 3]
Phase 7: Real-Sample Ground-Truthing & Refinement    [Milestone 3]
Phase 8: Official Labour/Industry Data Integration   [Milestone 4]
Phase 9: Interactive Analytical Dashboard (Shiny)    [Milestone 4]
Phase 10: Academic Reporting & Reproducibility Audit [Milestone 5]
```

---

## 3. Detailed Phase Specifications

### Phase 0 — Project Initialization
- Create standardized directory structure (`docs/`, `data/`, `R/`, `dashboard/`, `outputs/`, `tests/`).
- Establish `README.md` and core specifications.
- Configure R execution environment.

### Phase 1 — Data Requirements & Sourced Sample Curation
- Establish the data source register with explicit provenance fields.
- Assemble a curated sample of real Sri Lankan IT job postings (~60–80 postings) across major career tracks.
- Capture raw, unedited text alongside normalized initial schema to discover real-world anomalies (salary non-disclosure, mixed experience formats, title variants).

### Phase 2 — Data Model & Standardization Taxonomies
- Define the schemas for `jobs`, `job_skills`, and `employment_indicators`.
- Construct lookup tables for career categories, seniority levels, work modes, and canonical skill mappings.
- Implement foreign-key constraints between jobs and skill entities.

### Phase 3 — Synthetic Development Generator
- Build a reproducible R generator (`R/generate_synthetic_data.R`) with deterministic seed (`set.seed(42)`).
- Synthesize structurally realistic records covering 2016–2026 for testing the analytical pipeline.
- Embed controlled data imperfections (casing discrepancies, title aliases, missing salary values).
- **Rule:** Synthetic data is strictly for pipeline verification and never treated as market evidence.

### Phase 4 — R Data Pipeline (Cleaning & Transformation)
- Build `R/03_clean.R` and `R/04_transform.R`.
- Implement string normalization, date parsing, numeric salary extraction, and experience parsing.
- Produce standardized datasets in `data/processed/`.

### Phase 5 — Core Descriptive & Statistical Analysis
- Implement `R/05_job_market_analysis.R` through `R/08_experience_analysis.R`.
- Compute volume trends, category market shares, skill frequencies, entry-level accessibility ratios, and compensation percentiles.

### Phase 6 — Visualization Engine
- Implement `R/10_visualizations.R` using `ggplot2`.
- Generate presentation-quality figures for time-series trends, skill heatmaps, salary distributions, and experience distributions.

### Phase 7 — Real-Sample Pipeline Validation
- Run the full analytical pipeline against the curated real-world dataset.
- Profile discrepancies, salary disclosure rates, and title ambiguities in real data vs. synthetic assumptions.

### Phase 8 — Official Labour Statistics Integration
- Ingest official DCS Labour Force Survey (LFS) and CBSL indicators into `R/09_employment_analysis.R`.
- Contextualize IT vacancy patterns within national unemployment, youth unemployment, and ICT service export trends.

### Phase 9 — Interactive Analytical Dashboard
- Implement an R Shiny dashboard (`dashboard/app.R`) with dynamic filtering by career category, year, skill, and experience level.

### Phase 10 — Evaluation & Reproducibility Audit
- Run full end-to-end automated test suite.
- Audit all figures and tables against underlying code and datasets.
- Finalize academic documentation and findings summary.

---

## 4. Approved Python Integration Layer (Hybrid Extension)

While the original implementation plan established R as the core statistical and econometric environment, a complementary **Python Ingestion & Orchestration Layer** was subsequently approved to handle external source adaptations and cross-platform pipeline automation:

```text
EXTERNAL RAW SOURCES / APIs / DUMPS
                ↓
    PYTHON INGESTION LAYER
    • python/ingestion/api_fetcher.py       (Extensible API client & mock adapter)
    • python/ingestion/source_adapters.py   (JSON / CSV / TSV format adapters)
                ↓
    PYTHON PREPROCESSING & GUARD
    • python/preprocessing/text_hygiene.py  (UTF-8 BOM, encoding, line-ending checks)
    • python/preprocessing/raw_validator.py (Provenance, schema & referential integrity)
                ↓
    STANDARDIZED RAW CSVs (data/real_sample/, data/synthetic/, data/processed/)
                ↓
    R ANALYTICAL PIPELINE (Phases 4–8: R/01_ to R/12_)
    • Core econometric transformations, inferential hypothesis testing, ggplot2 figures
                ↓
    PRESENTATION LAYER (Phase 9: R Shiny & Interactive Web UI)
                ↓
    MASTER ORCHESTRATOR CLI (python python/runner.py)
```

### Architectural Division of Responsibilities:
- **Python:** Raw data ingestion interfaces, multi-format schema translation, low-level text encoding hygiene, pre-flight provenance assertions, and test runner orchestration.
- **R:** Statistical computation, non-parametric hypothesis tests ($p$-values, effect sizes), econometric feature engineering, publication-grade `ggplot2` rendering, and interactive Shiny dashboards.
- **Frozen Integrity:** The introduction of Python does not alter or recompute any frozen empirical parameters ($n=80$ real postings, 39 employers, 290 skills, all statistical test values locked).
