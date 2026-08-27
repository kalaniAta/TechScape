# TechScape: Final Research Methodology Summary

## 1. Methodological Philosophy & Architecture

TechScape adopts a **dual-tier exploratory and descriptive empirical architecture** designed to analyze the structural evolution of the Sri Lankan IT labour market without confounding synthetic developmental models with empirical market reality.

```text
CONCEPTUAL METHODOLOGICAL ARCHITECTURE
┌─────────────────────────────────────────────────────────────────────────┐
│ 1. DATA GOVERNANCE & PROVENANCE                                         │
│    • Synthetic Development Set (n=300) → R pipeline stress testing      │
│    • Inferred Reference Set (n=60)    → Schema, aliases & regex rules   │
│    • Verified Empirical Sample (n=80)  → Primary empirical ground truth  │
│    • Official Macro Indicators (n=31) → National economic context       │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ 2. DATA PROCESSING & NORMALIZATION PIPELINE                             │
│    • Ingestion & Structural Validation (01_import.R, 02_validate.R)     │
│    • Canonical Mapping & Deduplication (03_clean.R)                     │
│    • Feature Engineering & Banding (04_transform.R)                     │
│    • Preservation of Raw Text (original_title, original_salary)         │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ 3. EMPIRICAL & STATISTICAL ANALYSIS ENGINE                              │
│    • Descriptive Analytics: Career shares, skill frequencies, salary IQR│
│    • Inferential Statistics: Kruskal-Wallis, Fisher Exact, Pearson Cor  │
│    • Macro Contextualization: DCS Unemployment & CBSL Export Time Series│
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ 4. DISSEMINATION & UNDERGRADUATE GUIDANCE                               │
│    • Standalone Interactive Dashboard (dashboard/index.html)            │
│    • Evidence-Grounded Student Advisory Handbook                        │
│    • Publication Visualizations & Tabular Datasets                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Data Cleaning & Feature Engineering Standards

1. **Title & Skill Normalization:**
   - Raw title aliases (*"Full Stack Dev"*, *"Associate SE"*, *"Quality Engineer"*) are mapped to canonical categories (`Software Engineering`, `QA & Test Automation`) while preserving the raw `original_title`.
   - Technical skill variants (e.g. `React.js`, `Python3`, `k8s`) are canonicalized (`React`, `Python`, `Kubernetes`) while maintaining exact raw strings in `job_skills_real_sample.csv`.
2. **Missing Salary Handling:**
   - Undisclosed salaries (56.25% of sample) are strictly preserved as `NA`.
   - No zero-imputation or artificial central value substitution is applied.
   - Disclosed LKR and USD-pegged contracts are segmented into separate analytical subsets.
3. **Experience Standardization:**
   - Text descriptions (e.g. *"Fresh graduate"*, *"3-5 years"*, *"5+ years"*) are extracted into numeric bounds (`experience_min`, `experience_max`).
   - Entry-level accessibility is defined as `experience_min <= 1` or `seniority_level %in% c('Intern', 'Junior')`.

---

## 3. Statistical Testing Methodology

1. **Kruskal-Wallis Test:** Evaluates whether required minimum experience differs across the 8 career categories without assuming normality.
2. **Fisher's Exact Test:** Evaluates independence between work mode flexibility (Flexible vs On-site) and numeric salary disclosure.
3. **Pearson & Spearman Correlation:** Quantifies the linear and monotonic relationship between minimum experience and monthly LKR salary midpoint ($n=26$).
4. **Wilcoxon Rank-Sum Test:** Compares required technical skill density (skills per posting) between entry-level and experienced postings.
