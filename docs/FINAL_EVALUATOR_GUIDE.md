# TechScape: Evaluator Guide & Academic Architecture Reference

## 1. Project Purpose & Scope

**TechScape** is an empirical, R-based analytical ecosystem that examines the structural evolution of the **Sri Lankan IT labour market**. Sourced from verified online job postings and official macroeconomic datasets, it delivers descriptive and inferential statistical insights without conflating synthetic models with empirical reality.

---

## 2. Research Questions (RQ1–RQ8)

- **RQ1 (Volume & Trends):** What are the growth patterns in Sri Lankan IT knowledge services?
- **RQ2 (Career Tracks):** How is advertised recruitment distributed across specialized IT disciplines?
- **RQ3 (Skills Demand):** Which programming languages, cloud stacks, and development tools dominate hiring requirements?
- **RQ4 (Accessibility):** What proportion of job opportunities are accessible to entry-level graduates ($\le 1$ year experience)?
- **RQ5 (Experience):** How do required years of experience vary across career tracks and seniority tiers?
- **RQ6 (Compensation):** What are the salary distributions, disclosure rates, and currency dynamics (LKR vs USD)?
- **RQ7 (Macro Context):** How do IT vacancy trends contextualize against national unemployment (DCS LFS) and ICT export revenue (CBSL)?
- **RQ8 (Adaptability):** How prevalent are flexible/hybrid work arrangements and modern cloud-native architectures?

---

## 3. Data Governance Architecture

TechScape strictly segregates datasets into distinct operational tiers:

```text
DATA TIER CLASSIFICATION
├── SYNTHETIC TESTING DATA (data/synthetic/): 300 records used exclusively for automated pipeline stress-testing.
├── INFERRED REFERENCE DATA (data/reference/): 60 template records used solely for regex & taxonomy design.
├── VERIFIED REAL DATA (data/real_sample/): 80 verified empirical job postings and 290 skills across 39 unique employers.
└── OFFICIAL MACRO DATA (data/processed/): 31 time-series indicators from DCS LFS bulletins and CBSL Annual Reports.
```

---

## 4. How to Run & Reproduce from a Clean State

TechScape provides single-command end-to-end reproducibility through either Python or R:

### Primary Master Orchestrator (Python Preflight + R Analytics + Verification):
```bash
python python/runner.py
```

### Direct R Ecosystem Execution:
```powershell
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" R/13_run_complete_ecosystem.R
```

This single command:
1. Validates text encoding, UTF-8 compliance, and schema provenance via Python pre-flight checks (`python/preprocessing/`).
2. Validates and ingests verified real postings ($n=80$) and macro indicators.
3. Cleans, standardizes, and engineers all derived analytical variables in R.
4. Calculates all descriptive statistics and generates 27 publication-quality figures and 35 tabular datasets.
5. Executes the 4 inferential statistical hypothesis tests.
6. Re-exports the frontend JSON bundle (`dashboard/data.js`).
7. Executes the automated test suites in Python (13 assertions) and R (16 assertions) with 100% pass verification.

---

## 5. Main Empirical Results Summary

- **Career Track Market Share ($n=80$):** Software Engineering (25.00%), Data & AI / ML (13.75%), Cloud & DevOps (12.50%), QA & Test Automation (11.25%), Cyber Security (10.00%), IT Systems & Infrastructure (10.00%), Management & Business Analysis (8.75%), UI/UX & Product Design (8.75%).
- **Entry-Level Opportunities:** 26.25% (21 of 80 postings).
- **Salary Transparency & Scale:** 43.75% disclosure rate; Disclosed LKR median is **LKR 330,000/month** (IQR: LKR 310,000; Mean: LKR 317,404; $n=26$). Disclosed USD-pegged share is **25.71%** (Median: USD $1,600/month; $n=9$).
- **Experience Requirement:** Mean **3.12 years**; Median **3.00 years** (IQR: 4.00 years, range: 0 to 8 years).
- **Work Mode Flexibility:** 65.00% Hybrid, 26.25% On-site, 8.75% Remote.

---

## 6. Corrected Inferential Statistical Results

| Hypothesis / Test | Method | Test Statistic | df | p-value | Academic Decision ($\alpha = 0.05$) |
|---|---|---|---|---|---|
| **$H_1$: Experience by Career Track** | Kruskal-Wallis Rank Sum | $\chi^2 = 14.243$ | 7 | $p = 0.0470$ | **Statistically Significant ($p < 0.05$)** |
| **$H_2$: Salary Disclosure by Work Mode** | Fisher's Exact Test | Odds Ratio = 0.558 | — | $p = 0.3126$ | **Not Statistically Significant** |
| **$H_3$: Experience vs Disclosed LKR Salary** | Pearson Correlation | $r = 0.955$ ($t = 15.79$) | 24 | $p < 0.00001$ | **Statistically Significant ($p < 0.001$)** (95% CI: $[0.901, 0.980]$; Spearman $\rho = 0.915$) |
| **$H_4$: Skill Density by Seniority** | Wilcoxon Rank-Sum | $W = 761.0$ | — | $p = 0.0880$ | **Not Statistically Significant** (Entry: 3.43 vs Exp: 3.70) |

---

## 7. Interactive Dashboard Access

- **Standalone Web UI:** Open [`dashboard/index.html`](file:///d:/projects/TechScape/dashboard/index.html) in any standard web browser (no local web server or node installation required).
- **R Shiny Companion:** Run [`dashboard/app.R`](file:///d:/projects/TechScape/dashboard/app.R) in RStudio (`shiny::runApp('dashboard')`).

---

## 8. Key Methodological Limitations

1. **Cross-Sectional Sample ($n=80$):** Reflects online vacancy demand collected in August 2026 across 39 formalized employers; it is an illustrative sample, not an exhaustive census of all employed IT professionals.
2. **Salary Non-Disclosure:** 56.25% non-disclosure introduces potential self-selection bias toward structured firms.
3. **Observational Bounds:** Correlation metrics ($r = 0.955$) denote linear associations in the sample, not causal mechanisms.
4. **Macro Population Disconnect:** National labor force metrics (DCS LFS) span all economic sectors, whereas the IT-BPM export industry represents a specialized subset (~160,000 workers).

---

## 9. Important Repository File Map
 
- **Python Master Orchestrator:** [`python/runner.py`](file:///d:/projects/TechScape/python/runner.py)
- **Python Ingestion Layer:** [`python/ingestion/api_fetcher.py`](file:///d:/projects/TechScape/python/ingestion/api_fetcher.py) & [`python/ingestion/source_adapters.py`](file:///d:/projects/TechScape/python/ingestion/source_adapters.py)
- **Python Preprocessing & Guard:** [`python/preprocessing/text_hygiene.py`](file:///d:/projects/TechScape/python/preprocessing/text_hygiene.py) & [`python/preprocessing/raw_validator.py`](file:///d:/projects/TechScape/python/preprocessing/raw_validator.py)
- **R Pipeline Runner:** [`R/13_run_complete_ecosystem.R`](file:///d:/projects/TechScape/R/13_run_complete_ecosystem.R)
- **Empirical Datasets:** [`data/real_sample/jobs_real_sample.csv`](file:///d:/projects/TechScape/data/real_sample/jobs_real_sample.csv) & [`data/real_sample/job_skills_real_sample.csv`](file:///d:/projects/TechScape/data/real_sample/job_skills_real_sample.csv)
- **Macro Dataset:** [`data/processed/macro_labour_indicators.csv`](file:///d:/projects/TechScape/data/processed/macro_labour_indicators.csv)
- **Academic Synthesis:** [`outputs/findings/final_academic_synthesis_report.md`](file:///d:/projects/TechScape/outputs/findings/final_academic_synthesis_report.md)
- **Automated Tests:** [`tests/test_python_pipeline.py`](file:///d:/projects/TechScape/tests/test_python_pipeline.py) & [`tests/data_quality/test_real_and_inferential.R`](file:///d:/projects/TechScape/tests/data_quality/test_real_and_inferential.R)
- **Interactive UI:** [`dashboard/index.html`](file:///d:/projects/TechScape/dashboard/index.html)
