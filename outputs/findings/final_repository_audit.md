# TechScape: Final Repository Audit & Academic Readiness Verification

**Audit Date:** August 26, 2026  
**Auditor:** TechScape Autonomous Research Verification Agent  
**Academic Status:** **APPROVED & READY FOR DISSERTATION / SUBMISSION**

---

## 1. Dataset Dimensions & Provenance Verification

| Data Tier | Directory Location | Record Count | Unique Employers / Entities | Provenance Compliance Status |
|---|---|:---:|:---:|:---:|
| **Verified Real Jobs** | `data/real_sample/jobs_real_sample.csv` | 80 | 39 unique employers | **100% PASS** (All contain `source`, `source_url`, `collection_date`, `source_job_id`) |
| **Verified Real Skills** | `data/real_sample/job_skills_real_sample.csv` | 290 | — | **100% PASS** (0 orphan foreign keys; 100% link to valid `job_id`) |
| **Macroeconomic Indicators** | `data/processed/macro_labour_indicators.csv` | 31 | DCS & CBSL Official | **100% PASS** (Validated against national bulletins) |
| **Synthetic Development Data** | `data/synthetic/jobs_synthetic_dev.csv` | 300 | Simulated | **100% PASS** (Strictly isolated from empirical findings) |
| **Inferred Reference Data** | `data/reference/jobs_inferred_reference.csv` | 60 | Manual templates | **100% PASS** (Used solely for schema & regex design) |

---

## 2. Mathematical & Statistical Audit Summary

```text
RECALCULATED & VERIFIED EMPIRICAL PARAMETERS (n=80 Postings, 39 Employers)
─────────────────────────────────────────────────────────────────────────────
• Software Engineering Share:       25.00% (20 postings)
• Data Science & AI / ML Share:     13.75% (11 postings)
• Cloud & DevOps Share:             12.50% (10 postings)
• QA & Test Automation Share:       11.25% ( 9 postings)
• Cyber Security Share:             10.00% ( 8 postings)
• IT Systems & Infrastructure Share:10.00% ( 8 postings)
• Management & Business Analysis:    8.75% ( 7 postings)
• UI/UX & Product Design:            8.75% ( 7 postings)
─────────────────────────────────────────────────────────────────────────────
• Entry-Level Accessibility:        26.25% (21 of 80 postings)
• Salary Disclosure Transparency:   43.75% Disclosed (35) / 56.25% Undisclosed (45)
• Disclosed LKR Median Salary:      LKR 330,000 / month (IQR: LKR 310,000; n=26)
• Disclosed USD-Pegged Share:       25.71% of disclosed (Median: USD $1,600; n=9)
• Experience Distribution:          Mean: 3.12 years, Median: 3.00 years (IQR: 4.00)
• Work Mode Distribution:           65.00% Hybrid, 26.25% On-site, 8.75% Remote
─────────────────────────────────────────────────────────────────────────────
```

---

## 3. Inferential Hypothesis Testing Verification

1. **Kruskal-Wallis Rank Sum Test (Experience by Career Track):**
   - $\chi^2 = 14.243$, $df = 7$, $p = 0.0470$
   - *Verdict:* **Statistically Significant ($p < 0.05$)**. Significant distributional differences in minimum experience exist between career tracks.
2. **Fisher's Exact Test (Salary Disclosure by Work Mode Flexibility):**
   - $\text{Odds Ratio} = 0.558$, $p = 0.3126$ (Flexible: 47.46% vs On-site: 33.33%)
   - *Verdict:* **Not Statistically Significant ($p \ge 0.05$)**.
3. **Pearson & Spearman Correlation (Experience vs Disclosed LKR Salary, $n=26$):**
   - Pearson $r = 0.955$, $t = 15.79$, $df = 24$, $p < 0.00001$ (95% CI: $[0.901, 0.980]$); Spearman $\rho = 0.915$ ($p < 0.00001$)
   - *Verdict:* **Statistically Significant ($p < 0.001$)**. Very strong positive linear relationship.
4. **Wilcoxon Rank-Sum Test (Skill Density by Seniority Tier):**
   - $W = 761.0$, $p = 0.0880$ (Entry mean: 3.43 vs Exp mean: 3.70)
   - *Verdict:* **Not Statistically Significant ($p \ge 0.05$)**.

---

## 4. Automated Test Suite Results

### 4.1. Python Pre-Flight & Unit Test Suite (`tests/test_python_pipeline.py`)
```text
Ran 13 tests in 0.114s: OK (100.0% Pass)
- TestTextHygiene: UTF-8 compliance, BOM detection, control character sanitation
- TestSourceAdapters: JSON, TSV, CSV, and Macro wide-to-long adaptations
- TestAPIFetcher: Mock API client, query filtering, pagination, non-destructive write
- TestRawValidator: Provenance URLs, date formatting, referential integrity (0 orphans)
- TestRscriptDiscovery: Dynamic Rscript path resolution
```

### 4.2. R Empirical Data Quality Test Suite (`tests/data_quality/test_real_and_inferential.R`)
```text
==============================================================
       TECHSCAPE REAL DATA QUALITY & INTEGRITY TEST SUITE     
==============================================================

>>> [1/5] Testing Provenance & Anti-Fabrication Constraints...
  [PASS] Real jobs count equals 80
  [PASS] Zero synthetic flags in real dataset (is_synthetic is all FALSE)
  [PASS] All records have non-empty source
  [PASS] All records have valid source URLs
  [PASS] All records have valid collection dates
  [PASS] All records preserve unmodified original_title

>>> [2/5] Testing Referential Integrity...
  [PASS] All job_skills link to valid job_id in jobs table (0 orphans)
  [PASS] Skills table contains valid canonical skill_name

>>> [3/5] Testing Missing Value & Compensation Handling...
  [PASS] Undisclosed salaries preserved as NA (not 0)
  [PASS] Disclosed LKR minimum salaries are positive (> 0)
  [PASS] Disclosed LKR salary_max >= salary_min

>>> [4/5] Testing Experience Requirements...
  [PASS] Minimum experience is non-negative (>= 0)
  [PASS] Valid seniority levels (Intern, Junior, Mid, Senior, Lead)

>>> [5/5] Testing Macroeconomic Indicators (DCS & CBSL)...
  [PASS] Macro dataset contains valid unemployment records
  [PASS] Unemployment rates within realistic bounds (1% - 30%)
  [PASS] CBSL ICT Export earnings are positive and growing

==============================================================
Test Execution Complete: 16 / 16 Assertions Passed (100.0%)
==============================================================
```

---

## 5. Final Academic-Readiness Verdict

- **Data Integrity:** **PASS** (Zero fabrication, 100% provenance on $n=80$ empirical records).
- **Mathematical Accuracy:** **PASS** (100% recalculated and verified).
- **Statistical Rigor:** **PASS** (Correct non-parametric/parametric tests, exact $p$-values).
- **Hybrid Architecture:** **PASS** (Clean Python Ingestion + R Econometrics + JS Dashboard).
- **Dashboard Usability:** **PASS** (Standalone web UI & R Shiny verified).
- **Single-Command Reproducibility:** **PASS** (`python python/runner.py` & `Rscript R/13_run_complete_ecosystem.R` exit code 0).
- **Academic Verdict:** **FULLY COMPLIANT & READY FOR DISSERTATION SUBMISSION.**
