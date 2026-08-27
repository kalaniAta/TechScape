# TechScape: Data Source Register

## 1. Register Overview

This document records the register of **intended and actually used data sources** for the TechScape analytical project, detailing source provenance, collection methodologies, accessibility constraints, obtained fields, and known limitations.

---

## 2. Real Job Advertisement Sources (Active Empirical Sample)

| Source Identifier | Source Name & Domain | Active Status | Collection Method | Records | Fields Obtained | Known Limitations & Selection Biases |
|---|---|---|---|---|---|---|
| `SRC_TOPJOBS_LK` | **TopJobs Sri Lanka** (`topjobs.lk`) | Active (Empirical Sample) | Structured capture from public postings | 42 | Title, Company, Location, Work Mode, Experience, Salary Text, Date Posted, Job URL | High salary non-disclosure (~57%); legacy format; overrepresents established Colombo enterprises. |
| `SRC_LINKEDIN_LK` | **LinkedIn Sri Lanka** (`linkedin.com/jobs`) | Active (Empirical Sample) | Public job view extraction | 28 | Title, Company, Location, Work Mode, Experience, Seniority, Required Skills | Skewed toward multinational tech export firms and remote-first overseas employers. |
| `SRC_ITPRO_LK` | **ITPro Sri Lanka** (`itpro.lk`) | Active (Empirical Sample) | Public tech board capture | 10 | Technical Title, Specialized Skills, Architecture Requirements, Experience | Specialized tech focus; smaller total listing volume. |

---

## 3. Official Macroeconomic & Labour Statistics Sources (Active Integration)

| Source Identifier | Source Name & Institution | Active Status | Publication Type | Indicators Obtained | Analytical Role & Methodological Notes |
|---|---|---|---|---|---|
| `SRC_DCS_LFS` | **Sri Lanka Labour Force Survey (LFS)** — Department of Census and Statistics (DCS) | Active (`data/processed/macro_labour_indicators.csv`) | Annual & Quarterly Bulletins (2016–2026) | National Unemployment Rate (Annual 2016–2025, Q1 2026), Youth Unemployment Rate (20–29), Female LFPR | Provides macro context for youth labor accessibility. Sourced from authoritative national survey census. |
| `SRC_CBSL_AR` | **Central Bank of Sri Lanka (CBSL)** Annual Reports | Active (`data/processed/macro_labour_indicators.csv`) | Annual Reports & External Sector Statistics (2019–2025) | Telecommunications, Computer & Information Services Export Earnings (USD Millions) | Tracks macro knowledge-services export trajectory (USD $985M in 2019 to $1,520M in 2025). |
| `SRC_SLASSCOM_WF` | **SLASSCOM National IT-BPM Workforce Survey Reports** | Active Reference | Periodic Industry Survey Reports (2019, 2024, 2025) | Industry workforce size estimates (113,000 in 2019; ~160,000 in 2025) | Self-reported survey data from participating IT-BPM firms. |

---

## 4. Development & Reference Datasets (Isolated from Empirical Analysis)

| Dataset Identifier | File Path | Usage Mode | Status | Purpose & Governance |
|---|---|---|---|---|
| `SYNTH_DEV_V1` | `data/synthetic/jobs_synthetic_dev.csv` | Testing & Dev Only | `SYNTHETIC` | 300 records used strictly for pipeline stress testing. **Zero empirical claims.** |
| `REF_INFERRED_V1` | `data/reference/jobs_inferred_reference.csv` | Reference Only | `INFERRED REFERENCE` | Schema design & regex development template. **Zero empirical claims.** |

---

## 5. Provenance & Data Audit Protocol

1. Every real-world job posting is traceable via `source`, `source_url`, `collection_date`, and `source_job_id`.
2. Raw unnormalized strings (`original_title`, `original_salary`, `original_experience`) are retained alongside analytical variables.
3. No synthetic or inferred records are aggregated into empirical findings.
