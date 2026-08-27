# TechScape: Academic Methodology, Data Limitations & Epistemic Boundaries

## 1. Executive Methodological Overview

This document presents the formal **methodological boundaries, data limitations, and epistemic constraints** governing the TechScape analytical platform. In accordance with rigorous academic standards in empirical labour-market research, all findings, statistical tests, and visualizations must be interpreted within these established parameters.

---

## 2. Key Methodological & Data Limitations

### 2.1. Empirical Sample Size Scope ($n = 80$)
- **Nature of Sample:** The active empirical dataset consists of **80 verified Sri Lankan IT job postings** collected across 39 distinct tech enterprises in August 2026.
- **Academic Caveat:** While this dataset provides authentic, traceable ground truth for discovering contemporary recruitment practices, it represents an **illustrative cross-sectional sample** rather than an exhaustive national census. Findings describe observed properties of the sample and must not be overgeneralized to unobserved market segments.

### 2.2. Advertised Vacancy Flow vs. Total Employment Stock
- **The Flow vs. Stock Distinction:** Job advertisements measure **active employer hiring flow** (marginal recruitment demand at a specific point in time). They do not measure the **total stock of currently employed IT professionals** in Sri Lanka.
- **Implication:** The absence of a legacy skill (e.g. COBOL, Oracle PL/SQL) in advertised vacancies does not indicate that systems relying on those technologies are inactive in existing operations; it indicates that active recruitment is concentrated in modern development stacks.

### 2.3. Salary Non-Disclosure & Self-Selection Bias
- **Empirical Non-Disclosure Rate:** In the verified sample, **56.25% of postings (45 of 80)** did not disclose numeric remuneration, utilizing qualitative terms (*"Negotiable"*, *"Competitive"*, *"Attractive Remuneration"*, *"Best in Industry"*).
- **Selection Bias:** Disclosed salaries ($n = 35$) tend to be concentrated in entry-level internships (where fixed allowances of LKR 40,000–50,000 are standardized) and export-oriented firms advertising USD-pegged packages ($n = 9$, USD $1,100–$2,500/month) to attract senior talent. Median and mean compensation metrics reflect only the disclosing subset and must not be interpreted as mandatory industry-wide wage floors.

### 2.4. Platform & Geographic Selection Bias
- **Platform Concentration:** Postings were collected from three primary digital channels: `TopJobs Sri Lanka`, `LinkedIn Sri Lanka`, and `ITPro Sri Lanka`.
- **Geographic Centralization:** Over 85% of physical corporate offices are located within the Western Province (Colombo, Nawala, Malabe, Battaramulla), reflecting the spatial concentration of Sri Lanka's IT export industry.
- **Informal Channels:** Roles filled through direct university career fairs, internal transfers, personal referrals, or informal networking are not captured in public online advertisements.

### 2.5. Macroeconomic Data Integration & Non-Conflation
- **Distinct Population Universes:**
  1. *DCS Labour Force Survey (LFS):* Measures nationwide unemployment and labor force participation across all 25 administrative districts and all economic sectors (agriculture, manufacturing, services).
  2. *CBSL Balance of Payments (BPM6):* Measures national export earnings from telecommunications, computer, and information services in USD Millions.
  3. *TechScape Job Postings Sample:* Measures micro-level vacancy characteristics of formal IT enterprises.
- **Principle of Non-Conflation:** Macroeconomic youth unemployment (12.8%) cannot be directly attributed to IT hiring swings, as the IT-BPM workforce (~160,000 professionals) comprises a specialized subset of the national labor force.

### 2.6. Observational Nature & Absence of Causal Claims
- **Correlation vs. Causation:** All statistical associations reported (e.g. Pearson $r = 0.955$ between experience and salary, Kruskal-Wallis $\chi^2 = 14.24$ across career tracks) reflect observational relationships within the sample. They do not demonstrate causal mechanisms.
- **Zero Prediction / Machine Learning:** Predictive forecasting, individual career recommenders, and automated employability scoring are explicitly out of scope for Version 1.

---

## 3. Data Governance & Provenance Rules Summary

```text
DATA TIER CLASSIFICATION & PERMITTED USAGE
┌───────────────────────┬──────────────────────┬──────────────────────────────────────────┐
│ Data Tier             │ Physical Location    │ Permitted Analytical Usage               │
├───────────────────────┼──────────────────────┼──────────────────────────────────────────┤
│ SYNTHETIC             │ data/synthetic/      │ Pipeline testing & code verification only│
│ INFERRED REFERENCE    │ data/reference/      │ Schema design & regex development only   │
│ VERIFIED REAL         │ data/real_sample/    │ Empirical labour market findings only    │
│ OFFICIAL MACRO        │ data/processed/      │ Macroeconomic context (DCS & CBSL)       │
└───────────────────────┴──────────────────────┴──────────────────────────────────────────┘
```
